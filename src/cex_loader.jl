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
  • Copies every original metadata block exactly
  • Replaces the original #!ctscatalog block with the new .token catalog entry
  • Ends with a single #!ctsdata block containing the tokenized lines
"""
function write_tokenized_cex(original_path::String, tokenized_data_lines::Vector{String}, config::Dict)
    output_path = get_output_path(config, "tokenized")
    mkpath(dirname(output_path))

    original_lines = readlines(original_path)
    open(output_path, "w") do io
        catalog_replaced = false
        in_data_block = false

        for line in original_lines
            stripped = strip(line)
            isempty(stripped) && continue

            # When we hit the original catalog block, replace it entirely
            if startswith(stripped, "#!ctscatalog") && !catalog_replaced
                catalog_replaced = true
                println(io, "#!ctscatalog")
                println(io, "urn#citationScheme#groupName#workTitle#versionLabel#exemplarLabel#online#lang")
                urn_base = config["input"]["text_urn"]
                println(io, "$urn_base.token:#line/speech/speaker/token,line/speech/text/token#Aristophanes#Frogs#Furman University#a derivative of $urn_base, tokenized by word and punctuation#true#grc")
                continue
            end

            # When we reach the first data block, stop copying original data
            if startswith(stripped, "#!ctsdata")
                in_data_block = true
                println(io, "#!ctsdata")
                # Insert our tokenized lines
                for tline in tokenized_data_lines
                    println(io, tline)
                end
                continue
            end

            # Copy everything else (headers, comments, etc.)
            if !in_data_block
                println(io, line)
            end
        end

        # Safety net: if the original file had no #!ctsdata
        if !in_data_block
            println(io, "#!ctsdata")
            for tline in tokenized_data_lines
                println(io, tline)
            end
        end
    end

    println("✅ Tokenized CEX written → $output_path")
    return output_path
end