# Pipeline: `.cex` to pubications


This pipeline will take a digital edition of a Greek text and generate several editions aimed at enhancing a reader's ability to understand the text.

You can follow this like a recipe. This version of the recipe starts with the file `source-data/texts/demeter.cex`, the *Homeric Hymn to Demeter*, and all commands, below, assume that we are working with this text.

## 1: Starting Data: CEX files

Initial user-supplied data is in the form of CTS texts serialized as `.cex` files. These reside in:

	source-data/texts

There are three example texts provided:

	source-data/texts/herodotus.cex # Herodotus' Histories
	source-data/texts/demeter.cex # The Homeric Hymn to Demeter
	source-data/texts/frogs-speech-speaker.cex # Aritophanes' Frogs

> `frogs-speech-speaker.cex` demonstrates a convention for serializing a citable text of a play that both captures speamer-attributions while allowing that 'paratext' to be excluded from certain analytical edition. (We don't necessarily want to in include the word "Chorus" in a word-count of the language of the play, for example).

## 2: Tokenize Editions

Edit the file `scripts/config.toml` based on your text. There are examples for each of the three demo texts. Rename the one you want to use to `config.toml`.

	cp scripts/config-demeter.toml scripts/config.toml


Tokenize the text, generating some additional indices, with:

	julia --project=. scripts/tokenize_cex.jl

This will generate several files:

1. A tokenized CEX edition in `data/tokenized/`.
1. A list of elided words, and a histogram thereof, in `/data/indexes/`. The use of these is explained below.
1. A token-histogran in `/data/indexes`. This consists of unique tokens (surface-forms), a count of each, and a list of token-level URNs to that form.
1. Two versions of a  vocabulary list of unique surface forms, excluding punctuation—one version in Unicode and one in Beta-Code—in `/data/vocabulary/`. The latter is optimized to provide input for morphological parsing using the legacy `morpheus` code. See below.

## 3: Morphological Parsing

Instructions for morphological parsing are to be found at `morph/README.md`. 

To follow them, copy the beta-code vocabulary file from `data/vocabulary/` to `morph/source-data/words.txt`.

*E.g.*

`cp data/vocabulary/The_Homeric_Hymn_to_Demeter_beta_vocabulary.txt morph/source-data/words.txt
`

> The results in `morph/output/WHATEVER-errors.log` can be used to correct errors in the original text. If you find some, got back to the original text, edit the text, and re-run all the steps to here. 


The resulting file `morph/output/analysis.txt` will be used in the next step.

## 4: Parse Morpheus Output to Triplets

This step will take a file, *e.g.* `morph/output/demeter-analysis.txt`, produced by `morpheus` and turn it into a `.tsv` files of "triplets" (actually, 5-plets):

    surface-form (Unicode) \t surface-form (Betacode) \t lemma (Unicode) \t lemma (BetaCode) \t part-of-speech-tag

Edit file `scripts/config.toml`, the `morphology` section to specify the input file, *e.g.* `morph/output/analysis.txt`, a name and location for the resulting triplets file, and a name a location for the error log.

Run: `julia --project=. scripts/parse_morpheus.jl`

This will result in the file:

	data/indexes/The_Homeric_Hymn_to_Demeter_morpheus_triplets.tsv


## 4: Associate Lemmata with LSJ URNs

The one thing missing from the output of #4 is any association between the *lemma* and a lexicon entry.

For decades, projects used string-matching to do this association. That is imprecise and laborious. So we will do all the work now, to create a simple index of lemmata to (possible) lexicon entries, with the latter identified unambiguously by URN.

Run: `julia --project=. scripts/align_lemmata.jl`

