You are helping me with a project to generate thoroughly annotated online texts in Ancient Greek for readers. The project repository is up-to-date at: &lt;https://github.com/Eumaeus/Dramaturg.jl/tree/main&gt;.

In the directory `ai_queries` are enumerated files of the queries that got us to the present state of the project. The output from the current code can be found in the directories `data` and `morph/output`, and for html editions, `editions` (which also includes template files.)

The directory `scripts` contains the scripts that constitute the current pipeline. This pipeline is described in `docs/Pipeline.md`. There are concise "recipes" specific to my three demonstration texts. The current output in `data/` is the result of me walking through each of these recipes.

The scripts of the pipeline depend on Julia code in the `src` directory.

Everything is driven from `scripts/config.toml`.

## A Custom Morphology-Maker?

Line 40 in `source-data/texts/frogs-speech-speaker.cex`:

	urn:cts:greekLit:tlg0019.tlg009.fu.sp:10.1.text#εἰ μὴ καθαιρήσει τις, ἀποπαρδήσομαι;

The word "ἀποπαρδήσομαι" seems to mean "I will fart forth", from the word "πέρδομαι" (LSJ-urn: `urn:cite2:hmt:lsj.chicago_md:n81011`). But the lexicon says "only in compounds", like "ἀποπέρδομαι", which must be the *lemma* for the form in *Frogs*, line 10. 

But Morpheus will never offer a parsing that suggests that it is a form of "πέρδομαι" (the best it can come up with is "παρά-δέω", "I fasten to").

So this is the first example of what I knew was coming: a morphological form for which I will have to hand-craft a morphological entry and have it roll into the pipeline during the build.

### Rolling User-Generated Morphology Into the Pipeline

I have added to the `config.toml` yet another property:

`["editorial"]["user_morphology_dir"]`

I imagine a collection of `.tsv` files in that directory of user-generated forms.

Each file would follow the format of the output of `scripts/align_lemmata.jl`, which produces files like `data/indexes/Aristophanes_Frogs/Aristophanes_Frogs_triplets_lemmata.tsv`

I would like to modify two scripts so they process not only the lines of `["morphology"]["morph_lemmata_alignment"]`, but also the contents of any `.tsv` file in `["editorial"]["user_morphology_dir"]`. 

I would like to have this happen both at the initialization of a new morphological dictionary: `scripts/initial_cex.jl` and also when updating a morphological dictionary: `scripts/update_morphology_dictionary.jl`. In the latter case, if an identical form is already present, it will just be skipped.

Error-checking `["editorial"]["user_morphology_dir"]`: There should be some error-checking to confirm that a line is of the correct form: 6 tab-separated records: unicode-surface-form, betacode-surface-form, unicode-lemma, betacode-lemma, LSJ-URN, part-of-speech-tag.

The line I would first put into a `.tsv` file in `["editorial"]["user_morphology_dir"]` would be this:

~~~
ἀποπαρδήσομαι	a)popardh/somai	πέρδομαι	pe/rdomai	urn:cite2:hmt:lsj.chicago_md:n81011	v1sfim---
~~~

I have created a sample file, with my word from the *Frogs* at `source-data/morphology/user-generated/user_generated_forms1.tsv`, the location specified in `["editorial"]["user_morphology_dir"]`, in the `config.toml`.

This is checked into GitHub, with all latest changes.

x