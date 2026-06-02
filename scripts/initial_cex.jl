# ai_queries/populate_initial_greek_morphology_from_demeter.jl
# Run from project root: julia ai_queries/populate_initial_greek_morphology_from_demeter.jl

using Dates
using BetaReader          # required for beta_to_unicode inside morphology.jl
include("../src/morphology.jl")

const TSV_PATH = "data/indexes/The_Homeric_Hymn_to_Demeter_triplets_lemmata.tsv"
const CEX_PATH = "source-data/dictionaries/Greek_Morphology.cex"

# Generate a date-time base for unique object IDs (your preferred style)
base_time = Dates.format(Dates.now(Dates.UTC), "yyyymmddTHHMMSS")
println("Populating Greek_Morphology.cex using base timestamp: $base_time")

# Read the TSV (no header, 6 tab-separated columns)
tsv_lines = readlines(TSV_PATH)
new_entries = String[]

for (idx, line) in enumerate(tsv_lines)
    isempty(strip(line)) && continue
    fields = split(line, '\t')
    length(fields) != 6 && continue

    uc_form   = strip(fields[1]) |> String
    bc_form   = strip(fields[2]) |> String
    uc_lemma  = strip(fields[3]) |> String
    bc_lemma  = strip(fields[4]) |> String
    lsj       = strip(fields[5]) |> String
    pos       = strip(fields[6]) |> String

    isempty(uc_form) && continue

    # Use your exact describe_pos (markdown = true) and append LSJ link
    desc_base = describe_pos(bc_form, bc_lemma, pos, markdown=true)
    desc      = desc_base * ". See `$lsj`."

    # Unique CITE2-URN object identifier (date-time + 4-digit sequence)
    object_id = base_time * lpad(string(idx), 4, '0')
    full_urn  = "urn:cite2:fufolio:greekmorph.2026a:" * object_id

    # Build the exact # -separated data line required by the .cex
    data_line = join([full_urn, desc, uc_form, bc_form, uc_lemma, bc_lemma, lsj, pos], "#")
    push!(new_entries, data_line)
end

# Append to the CEX file (header + #!citedata line already exist)
open(CEX_PATH, "a") do io
    for entry in new_entries
        println(io, entry)
    end
end

println("✅ Added $(length(new_entries)) morphological forms to $CEX_PATH")
println("   (next step: run the incremental script on new texts)")

