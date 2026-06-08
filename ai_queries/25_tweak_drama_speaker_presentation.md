You are helping me with a project to generate thoroughly annotated online texts in Ancient Greek for readers. The project repository is up-to-date at: &lt;https://github.com/Eumaeus/Dramaturg.jl/tree/main&gt;.

In the directory `ai_queries` are enumerated files of the queries that got us to the present state of the project. The output from the current code can be found in the directories `data` and `morph/output`, and for html editions, `editions` (which also includes template files.)

The directory `scripts` contains the scripts that constitute the current pipeline. This pipeline is described in `docs/Pipeline.md`. There are concise "recipes" specific to my three demonstration texts. The current output in `data/` is the result of me walking through each of these recipes.

The scripts of the pipeline depend on Julia code in the `src` directory.

Everything is driven from `scripts/config.toml`.

## Alignment Challenge

I'd like help making an adjustment to the file at: `scripts/generate_html_reader_pages.jl`.

Specifically the `render_greek_text()` function.

It has to do with when the speaker-attribution appears in the HTML text.

I'll use the original `.cex` file that is the basis for the pipeline to illustrate: `source-data/texts/frogs-speech-speaker.cex`.

You helped me solve the hard part, when the speaker changes in the middle of a poetic line, as in lines 31–34 of the source text:

```
urn:cts:greekLit:tlg0019.tlg009.fu.sp:7.1.speaker#Διόνυσος
urn:cts:greekLit:tlg0019.tlg009.fu.sp:7.1.text#θαρρῶν γε· μόνον ἐκεῖν' ὅπως μὴ 'ρεῖς,
urn:cts:greekLit:tlg0019.tlg009.fu.sp:7.2.speaker#Ξανθίας
urn:cts:greekLit:tlg0019.tlg009.fu.sp:7.2.text#τὸ τί;
```

Currently the HTML is showing a speaker-attribution line after line even when the speaker has not changed. Lines 41–52 of the source text are an example:

```
urn:cts:greekLit:tlg0019.tlg009.fu.sp:11.1.speaker#Διόνυσος
urn:cts:greekLit:tlg0019.tlg009.fu.sp:11.1.text#μὴ δῆθ', ἱκετεύω, πλήν γ' ὅταν μέλλω 'ξεμεῖν.
urn:cts:greekLit:tlg0019.tlg009.fu.sp:12.1.speaker#Ξανθίας
urn:cts:greekLit:tlg0019.tlg009.fu.sp:12.1.text#τί δῆτ' ἔδει με ταῦτα τὰ σκεύη φέρειν,
urn:cts:greekLit:tlg0019.tlg009.fu.sp:13.1.speaker#Ξανθίας
urn:cts:greekLit:tlg0019.tlg009.fu.sp:13.1.text#εἴπερ ποιήσω μηδὲν ὧνπερ Φρύνιχος
urn:cts:greekLit:tlg0019.tlg009.fu.sp:14.1.speaker#Ξανθίας
urn:cts:greekLit:tlg0019.tlg009.fu.sp:14.1.text#εἴωθε ποιεῖν καὶ Λύκις κἀμειψίας;
urn:cts:greekLit:tlg0019.tlg009.fu.sp:16.1.speaker#Διόνυσος
urn:cts:greekLit:tlg0019.tlg009.fu.sp:16.1.text#μή νυν ποιήσῃς· ὡς ἐγὼ θεώμενος,
urn:cts:greekLit:tlg0019.tlg009.fu.sp:17.1.speaker#Διόνυσος
urn:cts:greekLit:tlg0019.tlg009.fu.sp:17.1.text#ὅταν τι τούτων τῶν σοφισμάτων ἴδω,
```

In the HTML text, "Ξανθίας" is labelled as the speaker for lines 12, 13, and 14, and "Διόνυσος" for lines 16 and 17 (the line-numbers are based on a printed edition… it is okay that there is not 15!).

I think we had this working at an earlier stage, and I can see evidence in the code that it is intended to act correctly!

I have pushed the latest code, and the HTML framework and the first html reader page to GitHub.