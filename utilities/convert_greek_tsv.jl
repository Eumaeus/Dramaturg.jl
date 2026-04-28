#!/usr/bin/env julia
# utilities/convert_greek_tsv.jl
# Usage: julia --project=. utilities/convert_greek_tsv.jl --input FILE --output FILE --column INT --to beta|unicode

#=

julia --project=. utilities/convert_greek_tsv.jl -i source-data/dictionaries/lsj_index.tsv -o tsv_test.tsv -c 2 -d beta

=#

using BetaReader
using ArgParse

function parse_commandline()
    s = ArgParseSettings()
    @add_arg_table s begin
        "--input", "-i"
            help = "Input file (Unicode or BetaCode Greek)"
            required = true
        "--output", "-o"
            help = "Output file"
            required = true
        "--column", "-c"
            help = "Column to transcode"
            required = true
        "--direction", "-d"
            help = "Direction: 'beta' (Unicode→BetaCode) or 'unicode' (BetaCode→Unicode)"
            arg_type = String
            default = "beta"
    end
    return parse_args(s)
end

function main()
    args = parse_commandline()
    input  = args["input"]
    output = args["output"]
    colstr = args["column"]
    col = parse(Int, colstr)
    dir    = lowercase(args["direction"])

    lines = readlines(input)
    converted = String[]

    for line in lines
        line = strip(line)
        line_parts = split(line, '\t')
        new_parts = []
        for i in eachindex(line_parts)
            if (i == col)
                temp_part = string(line_parts[i])
                if dir == "beta"
                    push!(new_parts, unicodeToBeta(temp_part))
                elseif dir == "unicode"
                    push!(new_parts, betaToUnicode(temp_part))
                else
                   error("Direction must be 'beta' or 'unicode'.")
               end
            else
                push!(new_parts, string(line_parts[i]))
            end
        end
        new_line = join(new_parts, '\t')
        push!(converted, new_line)

    end

    mkpath(dirname(output))
    write(output, join(converted, "\n") * "\n")
    println("✅ Converted $(length(converted)) lines → $output")
end

main()