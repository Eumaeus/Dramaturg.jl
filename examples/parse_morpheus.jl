using Dramaturg.Morphology   # or wherever you include it

#=

Parse raw output from Morpheus into triplets of:

    surface-form \t lemma \t part-of-speech-tag

julia --project=. examples/parse_morpheus.jl

=#

parse_morpheus_to_triplets(
    "morph/output/Aristophanes_Frogs_analysis.txt", 
    "data/indexes/Aristophanes_Frogs_morpheus_triplets.tsv",      
    "morph/output/Aristophanes_Frogs_parse_errors.log"
)


# Or test it on the hand-curated data:
#=
parse_morpheus_to_triplets(
    "morph/test-output/analysis.txt",
    "morph/test-output/test-triplets.tsv",
    "morph/test-output/parse_errors.log"
)
=#


