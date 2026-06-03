# utilities/generate_lsj_short_defs.jl
#
# One-time utility script to generate source-data/dictionaries/lsj_short_defs.tsv
# from the LSJ Chicago CEX file.
#
# Run once from the repository root with:
#   julia utilities/generate_lsj_short_defs.jl
#
# It reads only lsj_chicago.cex (skipping the 58-line header as specified)
# and produces a TSV with columns: urn\tshortened-entry
# exactly following the short-definition rules you described.

using Printf

# ----------------------------------------------------------------------
# Helper functions
# ----------------------------------------------------------------------

"""
Extract all **bold** strings from an LSJ entry (Markdown).
Returns them in the order they appear.
"""
function extract_bold_meanings(entry::AbstractString)::Vector{String}
    # Non-greedy match for anything between ** and ** (no nested ** assumed)
    matches = eachmatch(r"\*\*([^\*]+?)\*\*", entry)
    return [strip(m.captures[1]) for m in matches]
end

"""
Remove duplicate meanings while preserving first-appearance order.
"""
function unique_preserve_order(items::Vector{String})::Vector{String}
    seen = Set{String}()
    result = String[]
    for item in items
        if !isempty(item) && !(item in seen)
            push!(seen, item)
            push!(result, item)
        end
    end
    return result
end

"""
Strip only trailing sentence-level punctuation (. ; : ! ?) from a meaning.
Commas and internal punctuation are left untouched.
"""
function strip_ending_punctuation(s::AbstractString)::String
    # Remove one or more trailing . ; : ! ? (but not commas)
    return replace(s, r"[.;:!?]+$" => "")
end

# ----------------------------------------------------------------------
# Main script
# ----------------------------------------------------------------------

# Paths relative to the utilities/ directory
const CEX_PATH = joinpath(@__DIR__, "..", "source-data", "dictionaries", "lsj_chicago.cex")
const TSV_PATH = joinpath(@__DIR__, "..", "source-data", "dictionaries", "lsj_short_defs.tsv")

# Read the entire CEX file
lines = readlines(CEX_PATH)

println("Reading $(length(lines)) lines from lsj_chicago.cex…")

open(TSV_PATH, "w") do io
    processed = 0
    for i in 59:length(lines)          # data starts after line 58
        line = strip(lines[i])
        isempty(line) && continue

        # CEX data lines have exactly four fields separated by |
        # (limit=4 ensures that any | characters inside the Markdown entry
        # are kept inside the final field)
        parts = split(line, '#'; limit=4)
        length(parts) != 4 && continue

        urn   = strip(parts[2])
        entry = strip(parts[4])

        println(urn)

        # Extract, deduplicate, and clean the bold meanings
        raw_meanings = extract_bold_meanings(entry)
        unique_meanings = unique_preserve_order(raw_meanings)
        meanings = [strip_ending_punctuation(m) for m in unique_meanings]

        # Build the shortened definition exactly as specified
        if isempty(meanings)
            shortened = ""
        elseif length(meanings) <= 9
            shortened = join(meanings, "; ")
        else
            first_five = join(meanings[1:6], "; ")
            last_three = join(meanings[end-2:end], "; ")
            omitted    = length(meanings) - 9
            shortened  = first_five * "; …[$omitted omitted]… " * last_three
        end

        # Write TSV line
        println(io, urn, "\t", shortened)
        processed += 1
    end

    println("✓ Wrote $processed short-definition entries to:")
    println("  ", TSV_PATH)
end