#!/usr/bin/env julia
# scripts/check_duplicate_urns.jl
#
# Quick utility to scan any .cex file and report duplicate CTS-URNs.
# Works on your source-data/texts/*.cex files (and any other CEX-style file).
#
# Usage:
#   julia scripts/check_duplicate_urns.jl source-data/texts/frogs-speech-speaker.cex
#   julia scripts/check_duplicate_urns.jl source-data/texts/demeter.cex
#   julia scripts/check_duplicate_urns.jl source-data/texts/herodotus.cex
#
# If no argument is given it checks all three of your texts automatically.

using Printf

function find_duplicate_urns(cex_path::String)
    urn_to_lines = Dict{String, Vector{Int}}()
    line_num = 0

    for line in eachline(cex_path)
        line_num += 1
        line = strip(line)
        isempty(line) && continue
        startswith(line, '#') && continue          # skip headers / comments

        # Split on tabs (standard for CEX data lines)
        fields = split(line, '\t')
        isempty(fields) && continue

        # First field is almost always the URN in our files
        candidate = strip(fields[1])
        if startswith(candidate, "urn:cts:") || startswith(candidate, "urn:cite2:")
            urn = candidate
            if !haskey(urn_to_lines, urn)
                urn_to_lines[urn] = Int[]
            end
            push!(urn_to_lines[urn], line_num)
        end
    end

    # Find duplicates
    duplicates = Dict{String, Vector{Int}}()
    for (urn, lines) in urn_to_lines
        if length(lines) > 1
            duplicates[urn] = lines
        end
    end

    # Report
    if isempty(duplicates)
        @printf("✅ No duplicate CTS-URNs found in %s (%d data lines scanned)\n", basename(cex_path), line_num)
        return true
    else
        println("\n❌ Found $(length(duplicates)) duplicate CTS-URN(s) in $cex_path:\n")
        for (urn, lines) in sort(collect(duplicates), by = first)
            @printf("   • %s  (appears %d times)\n", urn, length(lines))
            @printf("     → lines: %s\n", join(lines, ", "))
        end
        return false
    end
end

# ------------------------------------------------------------------
# Main entry point
# ------------------------------------------------------------------
if length(ARGS) == 0
    # Default: check all three of your source files
    files = [
        "source-data/texts/demeter.cex",
        "source-data/texts/frogs-speech-speaker.cex",
        "source-data/texts/herodotus.cex"
    ]
    println("Checking all three source-text CEX files for duplicate URNs...\n")
    all_clean = true
    for f in files
        if !find_duplicate_urns(f)
            global all_clean = false
        end
    end
    println("\n" * (all_clean ? "🎉 All files are clean!" : "⚠️  Some files have duplicates (see above)."))
else
    # User supplied one file
    find_duplicate_urns(ARGS[1])
end