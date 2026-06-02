You are helping me with a project to generate thoroughly annotated online texts in Ancient Greek for readers. The project repository is up-to-date at: <https://github.com/Eumaeus/Dramaturg.jl/tree/main>.

So far we have been processing digital texts, analyzing words for morphology and lexicography, and incrementally building the indices from which we can make useful editions and perform other kinds of analysis.

In the directory `ai_queries` are enumerated files of the queries that got us to the present state of the project. The output from the current code can be found in the directories `data` and `morph/output`.

The directory `scripts` contains the scripts that constitute the current pipeline. This pipeline is described in `docs/Pipeline.md`. There are concise "recipes" specific to my three demonstration texts. The current output in `data/` is the result of me walking through each of these recipes.

The scripts of the pipeline depend on Julia code in the `src` directory.

## Background

We now have:

- A tokenized text, with each word citable by URN. *E.g.* `data/tokenized/Aristophanes_Frogs_tokenized.cex`.
- A dictionary of morphological forms, citable by URN, aligned to a lexicon. *E.g.* `source-data/dictionaries/Greek_Morphology.cex`

Along with some histograms, vocbulary lists, and other potentially useful data.

We are almost ready to generate editions for readers.

## Current Request

I would like to create an index for our tokenized text, indexing CTS-URNs from a tokenized text to CITE2-URNs from `source-data/dictionaries/Greek_Morphology.cex`.

The associations should be a surface-form that appears as a token in the CTS text and all entries in the `.cex` file with a matching surface form. 

Some text-tokens will result in one-to-one indexing; some will be one-to-many.

For example, this is line 29 of the file `data/tokenized/Aristophanes_Frogs_tokenized.cex`:

	urn:cts:greekLit:tlg0019.tlg009.fu.sp:2.1.text.token.3#ἀεὶ

The URN is:

	urn:cts:greekLit:tlg0019.tlg009.fu.sp:2.1.text.token.3

The surface-form `ἀεί` (note the acute accent) appears only once (line 11951) in `source-data/dictionaries/Greek_Morphology.cex`:

	urn:cite2:fufolio:greekmorph.2026a:20260602T1702307840#**ἀεί**. From **ἀεί**. Adverb. [d--------]. See `urn:cite2:hmt:lsj.chicago_md:n1564`.#ἀεί#a)ei/#ἀεί#a)ei/#urn:cite2:hmt:lsj.chicago_md:n1564#d--------

I would like the index to include the line:

		urn:cts:greekLit:tlg0019.tlg009.fu.sp:2.1.text.token.3 \t urn:cite2:fufolio:greekmorph.2026a:20260602T1702307840

As another example, from the tokenized text of *Frogs*:

	urn:cts:greekLit:tlg0019.tlg009.fu.sp:4.1.text.token.1#τοῦτο

The surface-form `τοῦτο` appears three times in `Greek_Morphology.cex`:

	urn:cite2:fufolio:greekmorph.2026a:20260602T1429082481#**τοῦτο**. From **οὗτος**. Noun. Neuter, nominative, singular. [n-s---nn-]. See `urn:cite2:hmt:lsj.chicago_md:n76062`.#τοῦτο#tou=to#οὗτος#ou(=tos#urn:cite2:hmt:lsj.chicago_md:n76062#n-s---nn-

	urn:cite2:fufolio:greekmorph.2026a:20260602T1429082482#**τοῦτο**. From **οὗτος**. Noun. Neuter, vocative, singular. [n-s---nv-]. See `urn:cite2:hmt:lsj.chicago_md:n76062`.#τοῦτο#tou=to#οὗτος#ou(=tos#urn:cite2:hmt:lsj.chicago_md:n76062#n-s---nv-

	urn:cite2:fufolio:greekmorph.2026a:20260602T1429082483#**τοῦτο**. From **οὗτος**. Noun. Neuter, accusative, singular. [n-s---na-]. See `urn:cite2:hmt:lsj.chicago_md:n76062`.#τοῦτο#tou=to#οὗτος#ou(=tos#urn:cite2:hmt:lsj.chicago_md:n76062#n-s---na-

So for this token, in the context of this text, the index would include three entries:

	urn:cts:greekLit:tlg0019.tlg009.fu.sp:4.1.text.token.1 \t urn:cite2:fufolio:greekmorph.2026a:20260602T1429082481
	urn:cts:greekLit:tlg0019.tlg009.fu.sp:4.1.text.token.1 \t urn:cite2:fufolio:greekmorph.2026a:20260602T1429082482
	urn:cts:greekLit:tlg0019.tlg009.fu.sp:4.1.text.token.1 \t urn:cite2:fufolio:greekmorph.2026a:20260602T1429082483

## Desiderata

I would like the script to be `scripts/index_morphology_to_tokens.jl`, with the other scripts in the pipeline.

It should use the existing config file, `scripts/config.toml`, using `src/config.jl`, getting the following variables like this:

~~~
  config = read_config()
  println("Loaded config for text: ", config["input"]["text_urn"])

  input = config["editorial"]["master_morph_dict"]
  output = config["morphology"]["morph_token_index"]
  errors = config["morphology"]["morph_token_index_errors"]
~~~

The errors-output will include any tokens in the tokenized edition that do not match an entry in `Greek_Morphology.cex`. Since `Greek_Morphology.cex` is build *from* the tokenized editions, failures to match will be of three kinds (at least that I can anticipate):

1. The token is a mark of punctuation. These are not errors to be reported, but should just be skipped.
2. The token failed either morphological parsing, or passed it but was not linked to a lexicon URN. These should be reported in the error list.
3. There is a transliteration problem somewhere in the various Betacode-Unicode transliterations. We should turn grave-accents to acute-accents before looking for a match, since `Greek_Morphology.cex` has normalized surface-forms. There will probably be others that, once reported, can be caught and fixed by tweaking the code.

*This will be a super-big deal, almost the last step in the long pipeline that you have helped me build. With this data in hand, many things are possible!*

