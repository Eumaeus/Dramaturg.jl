#!/usr/bin/env julia
# utilities/align-lemmata.jl
# Usage: julia --project=. utilities/align_lemmata.tsv -i PATH/TO/TRIPLETS.tsv -o PATH/TO/OUTPUT.tsv -l PATH/TO/BETA-LSJ.tsv -e PATH/TO/ERRORS.tsv

#=

Read in a .tsv file of token-records (--input) consisting of:

    surface-form \t lemma \t part-of-speech-tag

Read in an index to the LSJ lexicon (--lexindex)

Try to align the `lemma` with an LSJ entry. Write to --output:

    surface-form \t lemma \t lsj-urn \t part-of-speech-tag

If no match, write line to --errors:

    surface-form \t lemma \t "none-found" \t part-of-speech-tag

Try to resolve predictable ambiguities. If they cannot be resolved, write all possible answers to --errors:

        surface-form \t lemma \t urn1 \t part-of-speech-tag
        surface-form \t lemma \t urn2 \t part-of-speech-tag
        …

Defaults:

julia --project=. utilities/align_lemmata.jl -i data/indexes/Aristophanes_Frogs_morpheus_triplets.tsv -o data/indexes/Aristophanes_Frogs_triplets_lemmata.tsv -l source-data/dictionaries/lsj_index_beta.tsv -e data/indexes/Aristophanes_Frogs_triplets_lemmata_errors.tsv

SPECIAL CASES

le/gw - urn:cite2:hmt:lsj.chicago_md:n62204 should never be chosen. 
    Use urn:cite2:hmt:lsj.chicago_md:n62205




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
        "--lexindex", "-l"
            help = "Lexicon index"
            required = true
        "--errors", "-e"
            help = "Error file"
            required = true
    end
    return parse_args(s)
end

function main()
    args     = parse_commandline()
    input    = args["input"]
    output   = args["output"]
    lexindex = args["lexindex"]
    errors   = args["errors"]

    lex = readlines(lexindex)
    lines = readlines(input)
    converted = String[]
    bad_entries = String[]


    println("Beginning to process $(length(lines)) lines…")
    counter = 0

    for line in lines
        line = strip(line)
        line_parts = split(line, '\t')
        test_lemma = string(line_parts[2])
        new_parts = []
        good_entry = false # flag
      
        counter = counter + 1
        if (counter % 100) == 0
            print("$counter ") 
        end

        #================
        Logic 

        N.b. `test_lemma` is the current lemma from the input file of triplets.

        # filter lex for test_lemma as is, but removing hyphen
        ===============  =#
        lemma_with_number = test_lemma

        # Does the test lemma end in a number? 
        nls = match(r"(.+)([0-9]+)", lemma_with_number)
        # Get the lemma with no number
        test_lemma = nls !== nothing ? nls[1] : lemma_with_number

        # Get the number of the lemma; default to "1"
        lemma_number = nls !== nothing ? nls[2] : "1"

        # Remove any hyphens
        no_hyphen = replace(test_lemma, "-" => "")

        # Filter the lexicon for matching lemmata
        candidates = filter( entry -> begin
             cols = split(entry, "\t")
             string(cols[2]) == no_hyphen
           end, lex )

       
        # If exactly one hit… 
        #   complete the new entry with its URN!
        #   push onto output, `converted`

        if length(candidates) == 1

            entry = candidates[1]

            # Go ahead and keep the first two fields, surface-form and lemma 
            push!(new_parts, string(line_parts[1]))
            push!(new_parts, test_lemma)
            # Add the newly-discovered URN
            cols = split(entry, "\t")
            push!(new_parts, string(cols[1]))
            # Add the pos-tag at the end
            push!(new_parts, string(line_parts[3]))
            # pushnew line to output
            new_line = join(new_parts, '\t')
            push!(converted, new_line)
                
        # If more than one hit…
        #   If there was a number in the lemma, make that URN the top.
        #   but push them all onto output, `candidates` 

        elseif length(candidates) > 1

            for entry in candidates

                # Go ahead and keep the first two fields, surface-form and lemma 
                push!(new_parts, string(line_parts[1]))
                push!(new_parts, test_lemma)
                # Add the newly-discovered URN
                cols = split(entry, "\t")
                push!(new_parts, string(cols[1]))

                # Add the pos-tag at the end
                push!(new_parts, string(line_parts[3]))
                # pushnew line to output
                new_line = join(new_parts, '\t')
                push!(converted, new_line)

            end

        else
        #=== Write Bad Entry ===#
             # Go ahead and keep the first two fields, surface-form and lemma 
                push!(new_parts, string(line_parts[1]))
                push!(new_parts, test_lemma)
                # Add human-readable note that there is no entry found
                push!(new_parts, "- no urn found -")

                # Add the pos-tag at the end
                push!(new_parts, string(line_parts[3]))
                # Write new line to main index
                new_line = join(new_parts, '\t')
                push!(converted, new_line)
                # And to error log
                push!(bad_entries, new_line)


        end


    end

    mkpath(dirname(output))
    write(output, join(converted, "\n") * "\n")
    if (!isempty(bad_entries))
        write(errors, join(bad_entries, "\n") * "\n")
    end
    println("✅ Converted $(length(converted)) lines → $output")
end

main()