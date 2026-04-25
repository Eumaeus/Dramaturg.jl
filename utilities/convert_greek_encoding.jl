#!/usr/bin/env julia
# utilities/convert_greek_encoding.jl
# Usage: julia --project=. utilities/convert_greek_encoding.jl --input FILE --output FILE --to beta|unicode

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
    dir    = lowercase(args["direction"])

    lines = readlines(input)
    converted = String[]

    for line in lines
        line = strip(line)
        safestring = replace(line, "ʼ" => s"'") # fix elision marks
        isempty(safestring) && continue

        if dir == "beta"
            push!(converted, unicodeToBeta(safestring))
        elseif dir == "unicode"
            push!(converted, betaToUnicode(safestring))
        else
            error("Direction must be 'beta' or 'unicode'")
        end
    end

    mkpath(dirname(output))
    write(output, join(converted, "\n") * "\n")
    println("✅ Converted $(length(converted)) lines → $output")
end

main()