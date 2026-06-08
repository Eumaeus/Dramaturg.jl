You are helping me with a project to generate thoroughly annotated online texts in Ancient Greek for readers. The project repository is up-to-date at: &lt;https://github.com/Eumaeus/Dramaturg.jl/tree/main&gt;.

In the directory `ai_queries` are enumerated files of the queries that got us to the present state of the project. The output from the current code can be found in the directories `data` and `morph/output`, and for html editions, `editions` (which also includes template files.)

The directory `scripts` contains the scripts that constitute the current pipeline. This pipeline is described in `docs/Pipeline.md`. There are concise "recipes" specific to my three demonstration texts. The current output in `data/` is the result of me walking through each of these recipes.

The scripts of the pipeline depend on Julia code in the `src` directory.

Everything is driven from `scripts/config.toml`.

## A Custom Morphology-Maker?

Line 40 in `source-data/texts/frogs-speech-speaker.cex`:

	urn:cts:greekLit:tlg0019.tlg009.fu.sp:10.1.text#εἰ μὴ καθαιρήσει τις, ἀποπαρδήσομαι;


