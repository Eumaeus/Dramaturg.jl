You are helping me with a project to generate thoroughly annotated online texts in Ancient Greek for readers. The project repository is up-to-date at: &lt;https://github.com/Eumaeus/Dramaturg.jl/tree/main&gt;.

In the directory `ai_queries` are enumerated files of the queries that got us to the present state of the project. The output from the current code can be found in the directories `data` and `morph/output`, and for html editions, `editions` (which also includes template files.)

The directory `scripts` contains the scripts that constitute the current pipeline. This pipeline is described in `docs/Pipeline.md`. There are concise "recipes" specific to my three demonstration texts. The current output in `data/` is the result of me walking through each of these recipes.

The scripts of the pipeline depend on Julia code in the `src` directory.

Everything is driven from `scripts/config.toml`.


## Next Steps

### Durable Editor's Picks

This is a follow-up to an earlier request, which is documented here: `ai_queries/21_Editor_Index.md`.

As the code stands, we are exported "editor's picks" in the form of a two-column index of CTS-URN and CITE2-URN, the former a citation to a token in the text, and the latter a citation to an entry in `["editorial"]["master_morph_dict"]`. That was tidy and neat, and would be a great idea if `master_morph_dict` were truly a stable resource, and its URNs were truly canonical.

But since the code, and the texts, will remain works-in-progress, it is entirely likely that those will change, rendering all existing editorial picks useless. If the edited text changes such that token-URNs change, there is no helping that. But we should be able to design a workflow so that editorial data survies a change to `master_morph_dict`. 

Here's a sample line from `data/morphology/Greek_Morphology.cex`:

	urn:cite2:fufolio:greekmorph.2026a:20260607T0312400081#**Θηραμένης**. From **θηράω**. Verb. Perfect, participle, middle-passive, feminine, genitive, singular. [v-srpefg-]. See `urn:cite2:hmt:lsj.chicago_md:n48722`.#Θηραμένης#*qhrame/nhs#θηράω#qhra/w#urn:cite2:hmt:lsj.chicago_md:n48722#v-srpefg-

The property-fields are defined thus:

	1   2    3       4       5        6        7   8
	urn#desc#uc_form#bc_form#uc_lemma#bc_lemma#lsj#pos


When we save a `.tsv` file of editor's picks, working in the UI, let's save it with the CTS-URN as a first column, and then the following fields separated by `\t`: 3, 4, 5, 6, 7, 8.

Field 2, `desc`, is simply a formatted human-readable expansion of the data in other fields, which could be regenerated and thus might change. 

So "identity", in terms of alignment of a token with its morphology and lexicography, is based on 3, 4, 5, 6, 7, 8.

When re-building the html site, then, the code should match a token (CTS-URN) with any entry in `["editorial"]["master_morph_dict"]` that matches in terms of those fields: 3, 4, 5, 6, 7, 8.

This way, if the morphology dictionary is rebuilt, the editorial data will still work.

I hope that makes sense!

Files that this change would touch:

- `scripts/generate_html_reader_pages.jl`
- `editions/templates/js/interactive.js`

### Updating Legacy Editorial Picks

I have a small number of editorial picks already documented. It would be useful to keep them. I would like a utility script, `utilties/update_editorial_picks.jl` that would:

- work off a `config.toml`
- read in any `.tsv` files in `["editorial"]["editor_index_files"]`
- working from `["editorial"]["master_morph_dict"]`, update the `.tsv` data from "CTS-URN <-> CITE2-URN" to the scheme described above
- save the result in `["editorial"]["editor_index_files"]` as "new_editorial_pics.tsv".

### Consolidating Editorial Picks

I would like a utility script, `utilities/consolidate_editorial_picks.jl` that would:

- work off a `config.toml`
- read in any `.tsv` files in `["editorial"]["editor_index_files"]`
- concatenate them into a single `.tsv` file.
- save the new file in the same directory as `editorial_picks_[DATE].tsv`

### Cleaning `master_morph_dict`

Somehow—and I don't know how—it seems that duplicate entries creep into `master_morph_dict`, that is, entries that have different CITE2 URNs, but the other properties are identical. I would like a utility script, `utilities/prune_morphology.jl`, which:

- accepts a path to a .cex file of morphology as a parameter
- finds duplicate entries (different URNs, otherwise identical data).
- keeps one and deletes the other (it doesn't matter which).
- saves the original file with the same name but ending in `-old-[DATE].cex`.
- saves the new, pruned file under the original name. 
