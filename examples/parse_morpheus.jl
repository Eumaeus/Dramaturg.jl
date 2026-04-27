using Dramaturg.Morphology   # or wherever you include it


parse_morpheus_to_triplets(
    "morph/output/analysis.txt",          # your real output
    "morph/output/frogs-morpheus_triplets.tsv",         # clean triplets you wanted
    "morph/output/frogs-parse_errors.log"
)


# Or test it on the hand-curated data:
#=
parse_morpheus_to_triplets(
    "morph/test-output/analysis.txt",
    "morph/test-output/test-triplets.tsv",
    "morph/test-output/parse_errors.log"
)
=#


