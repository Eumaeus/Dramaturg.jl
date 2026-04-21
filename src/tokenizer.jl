using Unicode   # ← new import for robust accent normalization

"""
    tokenize_line(text::String) :: Vector{String}
Split on any whitespace. Treats punctuation as separate tokens.
Keeps elision mark ʼ attached to its word (exactly as in your example).
"""
function tokenize_line(text::String)
    # Insert space before common Greek punctuation so they become their own tokens
    text = replace(text, r"([·,.;:!?()[\]])" => s" \1 ")
    # Split on whitespace, drop empty tokens
    tokens = split(text, r"\s+"; keepempty=false)
    return tokens
end


"""
    tokenize_to_exemplar(cex_data::Vector{Tuple{String,String}}, config::Dict)
Generate ONLY the tokenized data lines (urn.token.N#token).  
The catalog header is inserted by write_tokenized_cex.
"""
function tokenize_to_exemplar(cex_data::Vector{Tuple{String,String}}, config::Dict)
    tokenized_lines = String[]

    for (urn, text) in cex_data
        tokens = tokenize_line(text)
        for (i, tok) in enumerate(tokens)
            new_urn = "$urn.token.$(i)"
            push!(tokenized_lines, "$new_urn#$tok")
        end
    end

    return tokenized_lines
end

"""
    normalize_grave_to_acute(s::String) :: String
Convert any final grave accent to acute (the conventional presentation form).
Uses NFD/NFC decomposition so it works on all precomposed and combining Greek accents.
"""
function normalize_grave_to_acute(s::String)::String
    nfd = Unicode.normalize(s, :NFD)
    replaced = replace(nfd, '\u0300' => '\u0301')
    return Unicode.normalize(replaced, :NFC)
end

"""
    load_presentation_dict(config::Dict) :: Dict{String,String}
Load and merge all three editorial dictionaries into a single surface → presentation map.
Order of precedence: elision → enclitics → anastrophe.
"""
function load_presentation_dict(config::Dict)
    d = Dict{String,String}()
    editorial = get(config, "editorial", Dict())

    # 1. Elision dictionary (surface → expanded_form)
    if haskey(editorial, "elision_dict")
        path = editorial["elision_dict"]
        if isfile(path)
            open(path) do io
                readline(io)  # skip header
                for line in eachline(io)
                    isempty(strip(line)) && continue
                    cols = split(line, '\t'; limit=2)
                    length(cols) == 2 || continue
                    surface = strip(cols[1])
                    expanded = strip(cols[2])
                    if !isempty(surface) && !isempty(expanded)
                        d[surface] = expanded
                    end
                end
            end
        end
    end

    # 2. Enclitics dictionary (surface → presentation_form)
    if haskey(editorial, "enclitics_dict")
        path = editorial["enclitics_dict"]
        if isfile(path)
            open(path) do io
                readline(io)  # skip header
                for line in eachline(io)
                    isempty(strip(line)) && continue
                    cols = split(line, '\t'; limit=2)
                    length(cols) == 2 || continue
                    surface = strip(cols[1])
                    pres = strip(cols[2])
                    if !isempty(surface) && !isempty(pres)
                        d[surface] = pres
                    end
                end
            end
        end
    end

    # 3. Anastrophe dictionary (surface → presentation_form)
    if haskey(editorial, "anastrophe_dict")
        path = editorial["anastrophe_dict"]
        if isfile(path)
            open(path) do io
                readline(io)  # skip header
                for line in eachline(io)
                    isempty(strip(line)) && continue
                    cols = split(line, '\t'; limit=2)
                    length(cols) == 2 || continue
                    surface = strip(cols[1])
                    pres = strip(cols[2])
                    if !isempty(surface) && !isempty(pres)
                        d[surface] = pres
                    end
                end
            end
        end
    end

    println("Loaded $(length(d)) editorial presentation mappings")
    return d
end

"""
    get_presentation_form(surface::AbstractString, presentation_dict::Dict{String,String}) :: String
Return the canonical presentation form for any token.
Now accepts SubString{String} (from split) and uses the pre-loaded dictionary.
"""
function get_presentation_form(surface::AbstractString, presentation_dict::Dict{String,String})::String
    s = String(surface)  # safe conversion
    return get(presentation_dict, s, normalize_grave_to_acute(s))
end

"""
    generate_elision_index(...)  ← updated version
Uses the pre-loaded presentation dictionary for speed and now correctly handles SubString.
"""
function generate_elision_index(cex_data::Vector{Tuple{String,String}}, tokenized_cex::String, config::Dict)
    presentation_dict = load_presentation_dict(config)  # load once

    token_lines = split(tokenized_cex, '\n')
    elisions = Dict{String, Vector{String}}()

    for line in token_lines
        line = strip(line)
        isempty(line) && continue
        startswith(line, "#!") && continue
        if occursin('#', line)
            urn, form = split(line, '#'; limit=2)
            if occursin('ʼ', form)
                push!(get!(Vector{String}, elisions, form), urn)
            end
        end
    end

    # 1. Full index
    index_path = get_output_path(config, "elided_index")
    mkpath(dirname(index_path))
    open(index_path, "w") do f
        println(f, "form\ttoken_urn\texpanded_form\tpresentation_form")
        for form in sort(collect(keys(elisions)))
            expanded = get(presentation_dict, form, "")   # only elision gives expanded
            pres = get_presentation_form(form, presentation_dict)
            for urn in elisions[form]
                println(f, "$form\t$urn\t$expanded\t$pres")
            end
        end
    end

    # 2. Histogram
    hist_path = get_output_path(config, "elided_histogram")
    open(hist_path, "w") do f
        println(f, "frequency\telided_form\texpanded_form\tpresentation_form\tturns")
        sorted = sort(collect(elisions), by = x -> length(x[2]), rev=true)
        for (form, urns) in sorted
            freq = length(urns)
            expanded = get(presentation_dict, form, "")
            pres = get_presentation_form(form, presentation_dict)
            urn_list = join(urns, ",")
            println(f, "$freq\t$form\t$expanded\t$pres\t$urn_list")
        end
    end

    println("Elision index     → $index_path")
    println("Elision histogram → $hist_path")
end

"""
    generate_word_histogram(...)  ← updated version
Now uses the pre-loaded dictionary and correctly handles SubString tokens.
"""
function generate_word_histogram(tokenized_cex::String, config::Dict)
    presentation_dict = load_presentation_dict(config)  # load once

    token_lines = split(tokenized_cex, '\n')
    counts = Dict{String, Vector{String}}()   # presentation_form => [urns...]

    for line in token_lines
        line = strip(line)
        isempty(line) && continue
        startswith(line, "#!") && continue
        if occursin('#', line)
            urn, surface = split(line, '#'; limit=2)
            canonical = get_presentation_form(surface, presentation_dict)
            if haskey(counts, canonical)
                push!(counts[canonical], urn)
            else
                counts[canonical] = [urn]
            end
        end
    end

    hist_path = get_output_path(config, "word_histogram")
    mkpath(dirname(hist_path))

    open(hist_path, "w") do f
        println(f, "frequency\tform\tturns")
        sorted = sort(collect(counts), by = x -> length(x[2]), rev=true)
        for (form, urns) in sorted
            freq = length(urns)
            urn_list = join(urns, ",")
            println(f, "$freq\t$form\t$urn_list")
        end
    end

    println("Full word histogram → $hist_path")
end