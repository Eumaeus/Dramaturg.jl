using Unicode   # ← new import for robust accent normalization

const PUNCTUATION_REGEX = r"([-“”\"·.,;:!?{}…†()–—[\]])"

const PUNCTUATION_CHARS = Set(['-', '–', '—', '†', '“', '”', '"', '·', '.', ',', ';', ':', '!', '?', '{', '}', '…', '(', ')', '[', ']'])

"""
    is_punctuation(token::AbstractString) :: Bool
Return `true` if the token is a single punctuation character produced by our tokenizer.
"""
function is_punctuation(token::AbstractString)::Bool
    length(token) == 1 && token[1] in PUNCTUATION_CHARS
end

const TONOS_TO_OXIA = Dict(
    # lowercase
    '\u03AC' => '\u1F71',  # ά → ά
    '\u03AD' => '\u1F73',  # έ → έ
    '\u03AE' => '\u1F75',  # ή → ή
    '\u03AF' => '\u1F77',  # ί → ί
    '\u03CC' => '\u1F79',  # ό → ό
    '\u03CD' => '\u1F7B',  # ύ → ύ
    '\u03CE' => '\u1F7D',  # ώ → ώ
    # uppercase
    '\u0386' => '\u1FBB',  # Ά → Ά
    '\u0388' => '\u1FC9',  # Έ → Έ
    '\u0389' => '\u1FCB',  # Ή → Ή
    '\u038A' => '\u1FDB',  # Ί → Ί
    '\u038C' => '\u1FF9',  # Ό → Ό
    '\u038E' => '\u1FEB',  # Ύ → Ύ
    '\u038F' => '\u1FFB',  # Ώ → Ώ
    # (optional but harmless) dialytika+tonos pairs
    '\u0390' => '\u1FD3',  # ΐ → ΐ
    '\u03B0' => '\u1FE3',  # ΰ → ΰ
)

function ensure_oxia(s::String)::String
    # Replace tonos precomposed → oxia precomposed (fast, in-place friendly)
    for (tonos, oxia) in TONOS_TO_OXIA
        s = replace(s, tonos => oxia)
    end
    return s
end

"""
    tokenize_line(text::String) :: Vector{String}
Split on any whitespace. Treats punctuation as separate tokens.
Keeps elision mark ʼ attached to its word (exactly as in your example).
"""
function tokenize_line(text::String)
    # Insert space before common Greek punctuation so they become their own tokens
    text = replace(text, PUNCTUATION_REGEX => s" \1 ")
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
    nfc = Unicode.normalize(replaced, :NFC)
    return ensure_oxia(nfc)          # ← add this

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
                    safeline = ensure_oxia(line)
                    cols = split(safeline, '\t'; limit=2)
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
                    safeline = ensure_oxia(line)
                    cols = split(safeline, '\t'; limit=2)
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
                    safeline = ensure_oxia(line)
                    cols = split(safeline, '\t'; limit=2)
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
    nf = get(presentation_dict, ensure_oxia(s), ensure_oxia(normalize_grave_to_acute(s)))
    return ensure_oxia(nf)
 
end

"""
    extract_ctsdata_lines(cex_text::String) :: Vector{String}
Extract only the actual data lines (urn#surface_form) from all #!ctsdata blocks.
Completely ignores catalog, metadata, and block headers.
Handles multiple ctsdata blocks if present in the future.
"""
function extract_ctsdata_lines(cex_text::String)::Vector{String}
    lines = split(cex_text, '\n')
    data_lines = String[]
    in_data_block = false

    for raw_line in lines
        line = strip(raw_line)
        isempty(line) && continue

        if startswith(line, "#!ctsdata")
            in_data_block = true
            continue
        elseif startswith(line, "#!")
            in_data_block = false
            continue
        end

        # Only keep actual data lines inside a ctsdata block
        if in_data_block && occursin('#', line)
            push!(data_lines, line)
        end
    end
    return data_lines
end

"""
    generate_elision_index(cex_data::Vector{Tuple{String,String}}, tokenized_cex::String, config::Dict)
Create elision index and histogram using only lines inside #!ctsdata blocks.
"""
function generate_elision_index(cex_data::Vector{Tuple{String,String}}, tokenized_cex::String, config::Dict)
    presentation_dict = load_presentation_dict(config)

    data_lines = extract_ctsdata_lines(tokenized_cex)
    elisions = Dict{String, Vector{String}}()

    for line in data_lines
        urn, form = split(line, '#'; limit=2)
        if occursin('ʼ', form)
            push!(get!(Vector{String}, elisions, form), urn)
        end
    end

    # 1. Full index
    index_path = get_output_path(config, "elided_index")
    mkpath(dirname(index_path))
    open(index_path, "w") do f
        println(f, "form\ttoken_urn\texpanded_form\tpresentation_form")
        for form in sort(collect(keys(elisions)))
            expanded = get(presentation_dict, form, "")
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
    generate_word_histogram(tokenized_cex::String, config::Dict)
Create a full-vocabulary histogram using only lines inside #!ctsdata blocks.
Uses presentation_form for every token (elided forms get expanded first, then grave→acute or editorial override).
"""
function generate_word_histogram(tokenized_cex::String, config::Dict)
    presentation_dict = load_presentation_dict(config)
    filter_paratext = config["input"]["filter_paratext"]
    println("filter paratext: $filter_paratext")

    data_lines = extract_ctsdata_lines(tokenized_cex)
    counts = Dict{String, Vector{String}}()   # presentation_form => [urns...]

    for line in data_lines
        urn, surface = split(line, '#'; limit=2)
        # exclude "speaker" nodes!
        if (!isempty(filter_paratext))
            if (contains(urn, filter_paratext))
                continue
            end
        end
        canonical = get_presentation_form(surface, presentation_dict)
        if haskey(counts, canonical)
            push!(counts[canonical], urn)
        else
            counts[canonical] = [urn]
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