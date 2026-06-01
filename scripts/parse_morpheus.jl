using Dramaturg
using Dramaturg.Morphology   # or wherever you include it

#=

Parse raw output from Morpheus into triplets of:

    surface-form (Unicode) \t surface-form (Betacode) \t lemma \t part-of-speech-tag

julia --project=. scripts/parse_morpheus.jl

=#

config = read_config()
println("Loaded config for text: ", config["input"]["text_urn"])

morph_input = config["morphology"]["raw_morph_data"]
morph_output = config["morphology"]["morph_pos_triplets"]
morph_errors = config["morphology"]["morph_pos_errors"]


parse_morpheus_to_triplets(morph_input, morph_output, morph_errors)


# Or test it on the hand-curated data:
#=
parse_morpheus_to_triplets(
    "morph/test-output/analysis.txt",
    "morph/test-output/test-triplets.tsv",
    "morph/test-output/parse_errors.log"
)
=#


