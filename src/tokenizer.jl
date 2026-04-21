"""
    tokenize_line(text::String) :: Vector{String}
Split on any whitespace. Treats punctuation as separate tokens.
Keeps elision mark ʼ attached to its word (exactly as in your example).
"""
function tokenize_line(text::String)
    # Insert space before common Greek punctuation so they become their own tokens
    text = replace(text, r"([“”·,†.;:!?()[\]])" => s" \1 ")
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
    generate_elision_index(cex_data::Vector{Tuple{String,String}}, tokenized_cex::String)
Create two files:
1. Full elision index: form\t token-URN\t expanded-form (blank)
2. Frequency histogram: freq\t form\t expanded\t comma-separated-URNs (sorted descending)
"""
function generate_elision_index(cex_data::Vector{Tuple{String,String}}, tokenized_cex::String, config::Dict)
    # Parse the tokenized CEX we just generated to get token URNs
    token_lines = split(tokenized_cex, '\n')
    elisions = Dict{String, Vector{String}}()   # form => [urn1, urn2, ...]

    for line in token_lines
        line = strip(line)
        isempty(line) && continue
        startswith(line, "#!") && continue
        if occursin('#', line)
            urn, form = split(line, '#'; limit=2)
            if occursin('ʼ', form)
                if haskey(elisions, form)
                    push!(elisions[form], urn)
                else
                    elisions[form] = [urn]
                end
            end
        end
    end

    # 1. Full index
    index_path = get_output_path(config, "elided_index")
    mkpath(dirname(index_path))
    open(index_path, "w") do f
        println(f, "form\ttoken_urn\texpanded_form")
        for form in sort(collect(keys(elisions)))
            for urn in elisions[form]
                println(f, "$form\t$urn\t")
            end
        end
    end

    # 2. Frequency histogram
    hist_path = get_output_path(config, "elided_histogram")
    open(hist_path, "w") do f
        println(f, "frequency\telided_form\texpanded_form\turns")
        sorted = sort(collect(elisions), by = x -> length(x[2]), rev=true)
        for (form, urns) in sorted
            freq = length(urns)
            urn_list = join(urns, ",")
            println(f, "$freq\t$form\t\t$urn_list")
        end
    end

    println("✅ Elision index → $index_path")
    println("✅ Histogram     → $hist_path")
end

"""
    load_elision_dict(config::Dict) :: Dict{String,String}
Load the editorial dictionary of elided surface forms → expanded forms.
Returns an empty dict if the file is missing (so the pipeline never crashes).
"""
function load_elision_dict(config::Dict)
    if haskey(config, "editorial") && haskey(config["editorial"], "elision_dict")
        path = config["editorial"]["elision_dict"]
    else
        path = "source-data/editorial_dict_elision.tsv"
    end

    if !isfile(path)
        @warn "Editorial elision dictionary not found at $path — using empty dictionary"
        return Dict{String,String}()
    end

    d = Dict{String,String}()
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
    println("Loaded $(length(d)) editorial elision mappings")
    return d
end

"""
    generate_word_histogram(tokenized_cex::String, config::Dict)
Create a full-vocabulary histogram of every token in the play.
• Uses the editorial elision dictionary: elided forms with an entry appear under their expanded form.
• Elided forms without an entry appear exactly as they occur in the text.
• Output: data/indexes/<text>_word_histogram.tsv
"""
function generate_word_histogram(tokenized_cex::String, config::Dict)
    elision_dict = load_elision_dict(config)

    token_lines = split(tokenized_cex, '\n')
    counts = Dict{String, Vector{String}}()   # canonical_form => [urn1, urn2, ...]

    for line in token_lines
        line = strip(line)
        isempty(line) && continue
        startswith(line, "#!") && continue
        if occursin('#', line)
            urn, surface = split(line, '#'; limit=2)
            # Use expanded form when the editorial dictionary supplies one
            canonical = get(elision_dict, surface, surface)
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
        # sort by frequency descending
        sorted = sort(collect(counts), by = x -> length(x[2]), rev=true)
        for (form, urns) in sorted
            freq = length(urns)
            urn_list = join(urns, ",")
            println(f, "$freq\t$form\t$urn_list")
        end
    end

    println("Full word histogram → $hist_path")
end

