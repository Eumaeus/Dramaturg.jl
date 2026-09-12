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
  • Replaces the #!ctsdata payload with the tokenized lines
  • Skips all original data lines inside the ctsdata block
"""
function write_tokenized_cex(original_path::String, tokenized_data_lines::Vector{String}, config::Dict)
    output_path = get_output_path(config, "tokenized")
    println("=====\n$output_path\n======")
    mkpath(dirname(output_path))

    original_lines = readlines(original_path)
    open(output_path, "w") do io
        in_catalog_block = false
        cat_header_replaced = false
        in_data_block = false

        # Get new URN
        urn_base = config["input"]["text_urn"]
        urn_parts = split(urn_base, ":")
        bibpart = urn_parts[4]
        versionpart = split(bibpart, ".")[1:3]
        newexemplar = join(versionpart, ".") * ".tok"
        urn_parts[4] = newexemplar
        tokenized_urn = join(urn_parts, ":")

        for line in original_lines
            stripped = strip(line)
            isempty(stripped) && continue

            # === REPLACE CATALOG BLOCK (unchanged) ===
            if startswith(stripped, "#!ctscatalog")
                in_catalog_block = true
                println(io)  # blank line
                println(io, "#!ctscatalog")
                continue
            end
            if (cat_header_replaced && in_catalog_block)
                
                # Get new citationScheme
                entry_parts = split(stripped, "#")
                # add new URN
                entry_parts[1] = tokenized_urn
                # document new citationScheme
                cit_scheme = entry_parts[2] * "/token"
                entry_parts[2] = cit_scheme

                # New exemplar label
                entry_parts[6] = "tokenized"

                # Assemble new line
                new_entry = join(entry_parts, "#")
                println(io, new_entry)
                in_catalog_block = false
                continue
            elseif (in_catalog_block)
                    println(io, "urn#citationScheme#groupName#workTitle#versionLabel#exemplarLabel#online#lang")
                    cat_header_replaced = true
                    continue
            end


            # === DATA BLOCK ===
            if startswith(stripped, "#!ctsdata")
                println(io)  # blank line
                println(io, "#!ctsdata")

                println("------\n$(tokenized_data_lines[4])\n")

                for tline in tokenized_data_lines
                    # Gotta replace the URN!
                    tl_parts = split(tline, "#")
                    tl_urn = tl_parts[1]
                    urn_parts = split(tl_urn, ":")
                    tl_passage = urn_parts[5]
                    tl_parts[1] = tokenized_urn * tl_passage
                    new_tline = join(tl_parts, "#")
                    println(io, new_tline)
                end
                in_data_block = true
                continue   # do NOT write the original #!ctsdata line itself
            end

            # Skip every original data line while we are inside a ctsdata block
            if in_data_block
                if startswith(stripped, "#!")  # next block header → exit data mode
                    in_data_block = false
                else
                    continue  # skip original urn#text lines
                end
            end

            # === OTHER #! BLOCKS ===
            if startswith(stripped, "#!")
                println(io)  # blank line before block
            end

            println(io, line)
        end
    end

    println("Tokenized CEX written → $output_path")
    return output_path
end