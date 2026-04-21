
"""
    tokenize_line(text::String) :: Vector{String}
    ... (your existing function, unchanged)
"""

# … keep tokenize_to_exemplar and write_tokenized_cex exactly as they are …

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
    get_presentation_form(surface::String, config::Dict) :: String
Return the canonical presentation form for any token.
Priority: editorial dict (elision/enclitic/anastrophe) → automatic grave→acute.
"""
function get_presentation_form(surface::String, config::Dict)::String
    static_dict = load_presentation_dict(config)  # loaded once per run
    return get(static_dict, surface, normalize_grave_to_acute(surface))
end

"""
    generate_elision_index(...)  ← updated version
Now populates expanded_form (from elision dict) **and** uses presentation_form for display.
"""
function generate_elision_index(cex_data::Vector{Tuple{String,String}}, tokenized_cex::String, config::Dict)
    presentation_dict = load_presentation_dict(config)  # reuse the merged dict

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

    # 1. Full index (surface form + presentation)
    index_path = get_output_path(config, "elided_index")
    mkpath(dirname(index_path))
    open(index_path, "w") do f
        println(f, "form\ttoken_urn\texpanded_form\tpresentation_form")
        for form in sort(collect(keys(elisions)))
            expanded = get(presentation_dict, form, "")   # only elision gives expanded
            pres = get_presentation_form(form, config)
            for urn in elisions[form]
                println(f, "$form\t$urn\t$expanded\t$pres")
            end
        end
    end

    # 2. Histogram (now with presentation_form)
    hist_path = get_output_path(config, "elided_histogram")
    open(hist_path, "w") do f
        println(f, "frequency\telided_form\texpanded_form\tpresentation_form\tturns")
        sorted = sort(collect(elisions), by = x -> length(x[2]), rev=true)
        for (form, urns) in sorted
            freq = length(urns)
            expanded = get(presentation_dict, form, "")
            pres = get_presentation_form(form, config)
            urn_list = join(urns, ",")
            println(f, "$freq\t$form\t$expanded\t$pres\t$urn_list")
        end
    end

    println("Elision index     → $index_path")
    println("Elision histogram → $hist_path")
end

"""
    generate_word_histogram(...)  ← updated version
Uses presentation_form for every token (elided forms get expanded first, then grave→acute or editorial override).
"""
function generate_word_histogram(tokenized_cex::String, config::Dict)
    presentation_dict = load_presentation_dict(config)

    token_lines = split(tokenized_cex, '\n')
    counts = Dict{String, Vector{String}}()   # presentation_form => [urns...]

    for line in token_lines
        line = strip(line)
        isempty(line) && continue
        startswith(line, "#!") && continue
        if occursin('#', line)
            urn, surface = split(line, '#'; limit=2)
            canonical = get_presentation_form(surface, config)
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