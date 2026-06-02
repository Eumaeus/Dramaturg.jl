# ai_queries/incremental_add_morphology.jl
# Usage: julia ai_queries/incremental_add_morphology.jl path/to/new_triplets_lemmata.tsv
# (run from project root)

using Dates
using BetaReader
include("src/morphology.jl")

const CEX_PATH = "source-data/dictionaries/Greek_Morphology.cex"

# Get the new TSV from command-line argument (or hard-code if you prefer)
length(ARGS) == 0 && error("Provide the path to a *_triplets_lemmata.tsv file")
new_tsv = ARGS[1]

# 1. Build set of existing uniqueness keys from the current CEX
existing_keys = Set{Tuple{String,String,String,String}}()
cex_lines = readlines(CEX_PATH)
data_start = false
for line in cex_lines
    if startswith(line, "#!citedata")
        data_start = true
        continue
    end
    if data_start && !isempty(strip(line)) && occursin('#', line)
        fields = split(line, '#')
        length(fields) == 8 || continue
        uc_form  = strip(fields[3])
        uc_lemma = strip(fields[5])
        lsj      = strip(fields[7])
        pos      = strip(fields[8])
        push!(existing_keys, (uc_form, uc_lemma, lsj, pos))
    end
end
println("Loaded $(length(existing_keys)) existing morphological forms.")

# 2. Process the new TSV
tsv_lines = readlines(new_tsv)
new_entries = String[]
base_time = Dates.format(Dates.now(Dates.UTC), "yyyymmddTHHMMSS")
added = 0

for (idx, line) in enumerate(tsv_lines)
    isempty(strip(line)) && continue
    fields = split(line, '\t')
    length(fields) != 6 && continue

    uc_form   = strip(fields[1])
    bc_form   = strip(fields[2])
    uc_lemma  = strip(fields[3])
    bc_lemma  = strip(fields[4])
    lsj       = strip(fields[5])
    pos       = strip(fields[6])

    isempty(uc_form) && continue

    key = (uc_form, uc_lemma, lsj, pos)
    key in existing_keys && continue   # already present → skip

    # New form: generate desc + URN exactly as before
    desc_base = describe_pos(bc_form, bc_lemma, pos; markdown = true)
    desc      = desc_base * ". See `$lsj`."

    object_id = base_time * lpad(string(idx), 4, '0')
    full_urn  = "urn:cite2:fufolio:greekmorph.2026a:" * object_id

    data_line = join([full_urn, desc, uc_form, bc_form, uc_lemma, bc_lemma, lsj, pos], "#")
    push!(new_entries, data_line)
    push!(existing_keys, key)   # so we don't add it again in the same run
    added += 1
end

# 3. Append only the new entries
if added > 0
    open(CEX_PATH, "a") do io
        for entry in new_entries
            println(io, entry)
        end
    end
    println("✅ Added $added new morphological forms to $CEX_PATH")
else
    println("No new forms to add (all already present in the collection).")
end