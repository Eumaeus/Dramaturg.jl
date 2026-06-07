# utilities/update_editorial_picks.jl
# Converts legacy 2-column editorial picks (CTS-URN \t CITE2-URN)
# to the new durable 7-column format using the current master_morph_dict.

using TOML
using Dates

function update_editorial_picks(config_path::String="scripts/config.toml")
    config = TOML.parsefile(config_path)
    editorial = config["editorial"]
    editor_dir = editorial["editor_index_files"]
    master_path = editorial["master_morph_dict"]

    !isdir(editor_dir) && (println("No editor directory: $editor_dir"); return)

    # Build lookup: old CITE2 URN → (uc_form, bc_form, uc_lemma, bc_lemma, lsj, pos)
    master_lookup = Dict{String,NTuple{6,String}}()
    for line in readlines(master_path)
        l = strip(line)
        isempty(l) || !startswith(l, "urn:cite2:fufolio:greekmorph") && continue
        fields = split(l, '#')
        length(fields) < 8 && continue
        urn = strip(fields[1])
        master_lookup[urn] = (
            strip(fields[3]),
            strip(fields[4]),
            strip(fields[5]),
            strip(fields[6]),
            strip(fields[7]),
            strip(fields[8])
        )
    end

    tsv_files = filter(f -> endswith(lowercase(f), ".tsv"), readdir(editor_dir))
    isempty(tsv_files) && (println("No .tsv files in $editor_dir"); return)

    new_lines = String[]
    for tsv in tsv_files
        fullpath = joinpath(editor_dir, tsv)
        for line in readlines(fullpath)
            l = strip(line)
            isempty(l) && continue
            parts = split(l, '\t')
            length(parts) < 2 && continue
            cts = strip(parts[1])
            old_urn = strip(parts[2])
            if haskey(master_lookup, old_urn)
                f6 = master_lookup[old_urn]
                push!(new_lines, cts * "\t" * join(f6, "\t"))
            else
                @warn "No master entry for $old_urn (file $tsv) – skipped"
            end
        end
    end

    sort!(new_lines)
    new_file = joinpath(editor_dir, "new_editorial_picks.tsv")
    open(new_file, "w") do io
        for l in new_lines
            println(io, l)
        end
    end

    println("✅ Updated $(length(new_lines)) legacy picks → $new_file")
end

if abspath(PROGRAM_FILE) == abspath(@__FILE__)
    cfg = length(ARGS) > 0 ? ARGS[1] : "scripts/config.toml"
    update_editorial_picks(cfg)
end