You are helping me with a project to generate thoroughly annotated online texts in Ancient Greek for readers. The project repository is up-to-date at: &lt;https://github.com/Eumaeus/Dramaturg.jl/tree/main&gt;.

In the directory `ai_queries` are enumerated files of the queries that got us to the present state of the project. The output from the current code can be found in the directories `data` and `morph/output`, and for html editions, `editions` (which also includes template files.)

The directory `scripts` contains the scripts that constitute the current pipeline. This pipeline is described in `docs/Pipeline.md`. There are concise "recipes" specific to my three demonstration texts. The current output in `data/` is the result of me walking through each of these recipes.

The scripts of the pipeline depend on Julia code in the `src` directory.

Everything is driven from `scripts/config.toml`.


## Next Steps

Backing up from end-user UI issues, I would like help with the current bottleneck in the pipeline. This is (predictably) the code I wrote by myself without your help:

`scripts/align_lemmata.jl`

It takes forever to run, because it uses repeated `filter()` operations on `source-data/dictionaries/lsj_index_beta.tsv`. 

It is trying to match up lemmata in a file like `data/indexes/Aristophanes_Frogs_morpheus_triplets.tsv` with entries in betacode version of the index to the LSJ lexicon: `source-data/dictionaries/lsj_index_beta.tsv`. It accepts that it may find more than one match, and if so, it collects them all. Sometimes Morpheus produces lemmata with hyphens, or numbers, and this tries to account for that. It prefers an exact match, but failing that it will try to lower-case the text-lemma to find a match in the LSJ, and as a last resort it will try with no accents. Direresis (`+` in Beta Code) can be a problem.

I would value seeing what kind of efficiency (and improved accuracy in matching) you can come up with!