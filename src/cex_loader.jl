"""
    load_cex(cex_path::String)
Return only the data lines (urn#text) from *all* `#!ctsdata` blocks.
Ignores every header block. Preserves order of appearance.
"""
function load_cex(cex_path::String)
    lines = readlines(cex_path)
    data = Tuple{String,String}[]
    in_data_block = false

    for line in lines
        line = strip(line)
        isempty(line) && continue

        # Start of a new block
        if startswith(line, "#!")
            in_data_block = (line == "#!ctsdata")
            continue
        end

        # Only collect lines when we are inside a ctsdata block
        if in_data_block && occursin('#', line)
            urn, text = split(line, '#'; limit=2)
            push!(data, (strip(urn), strip(text)))
        end
    end
    return data
end
"""
    write_tokenized_cex(original_path::String, tokenized_data_lines::Vector{String}, config::Dict)
Write a complete tokenized CEX that:
  • Preserves every original metadata block exactly
  • Replaces the entire #!ctscatalog block with the clean .token version
  • Inserts a blank line before every #! block header
  • Uses the correct tokenized URN (…sp.token: with no extra colon)
"""
function write_tokenized_cex(original_path::String, tokenized_data_lines::Vector{String}, config::Dict)
    output_path = get_output_path(config, "tokenized")
    mkpath(dirname(output_path))

    original_lines = readlines(original_path)
    open(output_path, "w") do io
        catalog_replaced = false
        skip_lines = 0

        for line in original_lines
            stripped = strip(line)
            isempty(stripped) && continue

            # === REPLACE THE ENTIRE ORIGINAL CATALOG BLOCK ===
            if startswith(stripped, "#!ctscatalog") && !catalog_replaced
                catalog_replaced = true
                skip_lines = 2                     # skip the next two lines (header + original URN line)

                println(io)                        # blank line for readability
                println(io, "#!ctscatalog")
                println(io, "urn#citationScheme#groupName#workTitle#versionLabel#exemplarLabel#online#lang")

                urn_base = config["input"]["text_urn"]
                tokenized_urn = replace(urn_base, r":$" => ".token:")

                println(io, "$tokenized_urn#line/speech/speaker/token,line/speech/text/token#Aristophanes#Frogs#Furman University#a derivative of $urn_base, tokenized by word and punctuation#true#grc")
                continue
            end

            # Skip any lines we marked for skipping
            if skip_lines > 0
                skip_lines -= 1
                continue
            end

            # === DATA BLOCK ===
            if startswith(stripped, "#!ctsdata")
                println(io)                        # blank line
                println(io, "#!ctsdata")
                for tline in tokenized_data_lines
                    println(io, tline)
                end
                continue
            end

            # === OTHER #! BLOCKS (cexversion, citelibrary, etc.) ===
            if startswith(stripped, "#!")
                println(io)                        # blank line before block
            end

            println(io, line)
        end
    end

    println("✅ Tokenized CEX written → $output_path")
    return output_path
end