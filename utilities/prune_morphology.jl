# utilities/prune_morphology.jl
# Removes duplicate entries (different CITE2 URN but identical other fields)
# from a morphology CEX file.

#= Example line

1   urn:cite2:fufolio:greekmorph.2026a:20260615T1545330003
2   **Αἰγαῖον**. From **Αἰγαῖος**. Adjective. Masculine, accusative, singular. [a-s---ma-]. See `urn:cite2:hmt:lsj.chicago_md:n2118`.
3   Αἰγαῖον
4   *ai)gai=on
5   Αἰγαῖος
6   *ai)gai=os
7   urn:cite2:hmt:lsj.chicago_md:n2118
8   a-s---ma-




=#

using Dates

function prune_morphology(cex_path::String)
    !isfile(cex_path) && error("File not found: $cex_path")
    !endswith(cex_path, ".cex") && error("Must be a .cex file")

    # Grab the template file's lines
    template_path = "data/morphology/Greek_Morphology_template.cex"
    template_lines = readlines(template_path)


    lines = readlines(cex_path)
    sig_to_lines = Dict{Tuple{String,String,String,String,String,String,String}, Vector{String}}()


    for line in lines
        l = strip(line)
        isempty(l) && continue
        startswith(l, "urn:cite2:fufolio:greekmorph") || continue

        fields = split(l, '#')
        length(fields) < 8 && continue

        # signature = fields 2–8 (everything except the URN)
        sig = (
            strip(fields[2]),
            strip(fields[3]),
            strip(fields[4]),
            strip(fields[5]),
            strip(fields[6]),
            strip(fields[7]),
            strip(fields[8])
        )

        if !haskey(sig_to_lines, sig)
            sig_to_lines[sig] = String[]
        end
        push!(sig_to_lines[sig], l)
    end

    kept = String[]




    for (sig, lst) in sig_to_lines
        length(lst) > 1 && println("Pruned $(length(lst)-1) duplicate(s) for signature: $(sig[1])\t$(sig[2])\t$(sig[3])\t$(sig[4])")
        push!(kept, lst[1])  # keep any one
    end

    sort!(kept)

    # backup
    date_str = Dates.format(Dates.now(), "yyyymmdd")
    dirn, filen = splitdir(cex_path)
    old_name = replace(filen, r"\.cex$" => "-old-$(date_str).cex")
    old_path = joinpath(dirn, old_name)
    cp(cex_path, old_path; force=true)
    println("Backup: $old_path")

    open(cex_path, "w") do io
      # Add template_lines first
        for tl in template_lines
            println(io, tl)
        end
     # Now add data
        for l in kept
            println(io, l)
        end
    end

    println("Pruned morphology saved to $cex_path ( $( (length(lines)-length(template_lines))-length(kept) ) duplicates removed)")
end



if abspath(PROGRAM_FILE) == abspath(@__FILE__)
    length(ARGS) == 0 && error("Usage: julia utilities/prune_morphology.jl <path_to_Greek_Morphology.cex>")
    prune_morphology(ARGS[1])
end