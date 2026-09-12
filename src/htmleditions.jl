"""
HTML edition helpers — clean chunking for drama, prose, and poetry.
"""

using .Dramaturg  # for load_cex, read_config, etc.

"""
    parse_urn_passage(urn::String) -> (line_label::String, kind::String)

For drama only. Extracts line label (e.g. "244b") and kind ("speaker"/"text").
"""
function parse_urn_passage(urn::String)
    passage = split(urn, ':')[end]
    parts = split(passage, '.')
    line_label = parts[1]          # String — never parsed
    kind = parts[3]
    return line_label, kind
end

"""
    chunk_drama(data::Vector{Tuple{String,String}}, target::Int)

Drama-specific: groups by line → speech blocks (consecutive lines same speaker) → never splits blocks.
"""
function chunk_drama(data::Vector{Tuple{String,String}}, target::Int)
    lines = []
    current_line = nothing
    current_speaker = ""
    current_tokens = Tuple{String,String}[]

    for (urn, text) in data
        line_label, kind = parse_urn_passage(urn)

        if current_line === nothing || current_line != line_label
            if current_line !== nothing
                push!(lines, (current_line, current_speaker, current_tokens))
            end
            current_line = line_label
            current_tokens = Tuple{String,String}[]
            current_speaker = ""
        end

        push!(current_tokens, (urn, text))

        if kind == "speaker"
            current_speaker = text
        end
    end

    if current_line !== nothing
        push!(lines, (current_line, current_speaker, current_tokens))
    end

    # Group into speech blocks
    speech_blocks = []
    current_block = []
    for l in lines
        if isempty(current_block) || l[2] == current_block[end][2]
            push!(current_block, l)
        else
            push!(speech_blocks, current_block)
            current_block = [l]
        end
    end
    isempty(current_block) || push!(speech_blocks, current_block)

    # Greedy chunking (never split a speech block)
    chunks = Vector{Tuple{String,String}}[]
    current_chunk = Tuple{String,String}[]
    current_count = 0

    for block in speech_blocks
        block_tokens = vcat([l[3] for l in block]...)
        block_size = length(block_tokens)

        if current_count + block_size > target && current_count > 0
            push!(chunks, current_chunk)
            current_chunk = Tuple{String,String}[]
            current_count = 0
        end

        append!(current_chunk, block_tokens)
        current_count += block_size
    end

    isempty(current_chunk) || push!(chunks, current_chunk)
    return chunks
end

"""
    get_natural_unit(urn::String) -> String

For prose and poetry: drops the trailing ".token.N" from the CTS-URN passage.
This gives the natural citation unit (section, line, etc.).
"""
function get_natural_unit(urn::String)
    passage = split(urn, ':')[end]
    parts = split(passage, '.')
    # if length(parts) >= 3 && parts[end-1] == "token"
    if length(parts) >= 3 && startswith(parts[end], "token")
        unit_parts = parts[1:end-1]
        return join(unit_parts, '.')
    else
        return passage
    end
end

"""
    chunk_prose_or_poetry(data::Vector{Tuple{String,String}}, target::Int, citation_level::Int=1)

Prose & poetry: groups by natural unit → greedy packing, always keeping whole units together.
For citation_level == 2, never crosses top-level boundaries (e.g. book boundaries in Herodotus/Iliad).
"""
function chunk_prose_or_poetry(data::Vector{Tuple{String,String}}, target::Int, citation_level::Int=1)
    units = []
    current_unit = nothing
    current_tokens = Tuple{String,String}[]

    for (urn, text) in data
        unit = get_natural_unit(urn)

        if current_unit === nothing || current_unit != unit
            if current_unit !== nothing
                push!(units, current_tokens)
            end
            current_unit = unit
            current_tokens = Tuple{String,String}[]
        end

        push!(current_tokens, (urn, text))
    end

    isempty(current_tokens) || push!(units, current_tokens)

    # Greedy chunking with optional top-level boundary enforcement
    chunks = Vector{Tuple{String,String}}[]
    current_chunk = Tuple{String,String}[]
    current_count = 0
    current_top = nothing

    for unit_tokens in units
        unit_size = length(unit_tokens)
        top = nothing
        if citation_level == 2 && !isempty(unit_tokens)
            first_urn = unit_tokens[1][1]
            unit_cit = get_natural_unit(first_urn)
            parts = split(unit_cit, '.')
            top = !isempty(parts) ? parts[1] : nothing
        end

        should_new = (current_count + unit_size > target && current_count > 0) ||
                     (citation_level == 2 && current_top !== nothing && top !== nothing && current_top != top && current_count > 0)

        if should_new
            push!(chunks, current_chunk)
            current_chunk = Tuple{String,String}[]
            current_count = 0
        end

        append!(current_chunk, unit_tokens)
        current_count += unit_size
        current_top = top
    end

    isempty(current_chunk) || push!(chunks, current_chunk)
    return chunks
end

"""
    chunk_for_html_edition(config::Dict)

Main entry point. Dispatches by genre from config.toml and writes one .txt file per chunk.
Now respects citation_level for 2-level texts (never crosses book boundaries).
"""
function chunk_for_html_edition(config::Dict)
    data_root = config["processing"]["data_root"]
    tokenized_dir = config["processing"]["tokenized_dir"]
    file_name = config["input"]["file_name"]
    tokenized_suffix = config["processing"]["tokenized_suffix"]
    tokenized_path = joinpath(data_root, tokenized_dir, file_name * tokenized_suffix)

    html_temp_dir = config["output"]["html_temp_dir"]
    mkpath(html_temp_dir)

    tokens_per_page = config["output"]["html_tokens_per_page"]
    genre = lowercase(config["input"]["text_genre"])
    citation_level = get(config["input"], "citation_level", 1)  # defaults to 1

    data = load_cex(tokenized_path)
    println("Loaded $(length(data)) tokens from $tokenized_path")

    if genre == "drama"
        chunks = chunk_drama(data, tokens_per_page)
    elseif genre == "prose" || genre == "poetry"
        chunks = chunk_prose_or_poetry(data, tokens_per_page, citation_level)
    else
        error("Unknown genre: $genre. Supported: drama, prose, poetry.")
    end

    for (i, chunk) in enumerate(chunks)
        chunk_file = joinpath(html_temp_dir, "chunk_$(lpad(i, 3, '0')).txt")
        open(chunk_file, "w") do io
            for (urn, text) in chunk
                println(io, "$urn\t$text")
            end
        end
    end

    println("Chunking complete: $(length(chunks)) chunks written to $html_temp_dir")
    return nothing
end


export chunk_for_html_edition, get_natural_unit