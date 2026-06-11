# utilities/consolidate_editorial_picks.jl
# Concatenates all .tsv files in the editorial directory into one
# editorial_picks_[DATE].tsv (new 7-column format).

using TOML
using Dates

function consolidate_editorial_picks(config_path::String="scripts/config.toml")
    config = TOML.parsefile(config_path)
    editorial = config["editorial"]
    editor_dir = editorial["user_morphology_dir"]

    !isdir(editor_dir) && (println("No editor directory"); return)

    tsv_files = filter(f -> endswith(lowercase(f), ".tsv"), readdir(editor_dir))
    isempty(tsv_files) && (println("No .tsv files"); return)

    collected = String[]
    for tsv in tsv_files
        fullpath = joinpath(editor_dir, tsv)
        for line in readlines(fullpath)
            l = strip(line)
            isempty(l) && continue
            push!(collected, l)
        end
    end

    date_str = Dates.format(Dates.today(), "yyyymmdd")
    new_file = joinpath(editor_dir, "user_morphology_$(date_str).tsv")
    sort!(collected)

    open(new_file, "w") do io
        for l in collected
            println(io, l)
        end
    end

    println("✅ Consolidated $(length(collected)) lines → $new_file")
end

if abspath(PROGRAM_FILE) == abspath(@__FILE__)
    cfg = length(ARGS) > 0 ? ARGS[1] : "scripts/config.toml"
    consolidate_editorial_picks(cfg)
end