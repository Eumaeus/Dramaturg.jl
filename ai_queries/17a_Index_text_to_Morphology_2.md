You are helping me with a project to generate thoroughly annotated online texts in Ancient Greek for readers. The project repository is up-to-date at: <https://github.com/Eumaeus/Dramaturg.jl/tree/main>.

So far we have been processing digital texts, analyzing words for morphology and lexicography, and incrementally building the indices from which we can make useful editions and perform other kinds of analysis.

In the directory `ai_queries` are enumerated files of the queries that got us to the present state of the project. The output from the current code can be found in the directories `data` and `morph/output`.

The directory `scripts` contains the scripts that constitute the current pipeline. This pipeline is described in `docs/Pipeline.md`. There are concise "recipes" specific to my three demonstration texts. The current output in `data/` is the result of me walking through each of these recipes.

The scripts of the pipeline depend on Julia code in the `src` directory.

## Request

I want to return to the script you helped me make: `scripts/index_morphology_to_tokens.jl`

Output of its current run is at: `data/indexes/Aristophanes_Frogs_morphology_index.tsv`

That script worked well, as expected!

On line 72 of the script, I did get a scope-error and fixed it by adding `global`:

	global skipped += 1

The vast majority of the errors were elided forms, which is great!

We are already generating a list of elided forms for each text, *e.g.*

	data/indexes/Aristophanes_Frogs_elided_histogram.tsv

And I have a growing "elision dictionary":

	source-data/dictionaries/editorial_dict_elision.tsv

So we should add a step in the script that checks the elision dictionary to resolve elided forms before trying to associate them with entries in `Greek_Morphology.cex`.

That is, when looking to match a surface-form in the text that is elided, we should see if it appears in col 1 of `source-data/dictionaries/editorial_dict_elision.tsv`, and try matching based on the matching value in col 2.

