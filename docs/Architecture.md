# Architecture

The code in this repository intend to take as input a CEX-formatted text, and produce as output a rich publication of that text for human readers and for further analysis.

The challenge is wrestling lots of legacy data and tools going back over thirty years. Standards for encoding Geek, editorial conventions in the digital lexica, output from legacy code all present problems.

The goal is to capture declarative and unambiguous data wherever possible, doing all the fiddly computational work up front, as "once and for all" as possible.

## The Project

- Start with a Greek text, serialized in CEX format.
- Produce a "de-luxe" dataset of the language of that Greek text, in which…
	- Every token (words, punctuation), it citable by URN.
	- Every *lexical token* (Greek word) is associated with:
		- One or more morphological analyses.
		- A lexicon *lemma* for each morphological analysis.
		- A URN-citation to the LSJ lexicon for each possible morphological parsing.
- From this dataset, generate HTML editions aimed at helping people read the text.

The source-data of the project consists of:

- A corpus of CEX-serialized Greek texts.
- A digital edition of the *LSJ* lexicon, with word-articles citable by URN and encoded in Markdown for formatting for human readers.
- An index to the LSJ lexicon, facilitating associations of *lemmata* (Greek strings) with specific citable lexicon entries.
- A (growing) dictionary of Greek word forms, unique and citable by URN, consisting of a **form**, and a morphological parsing, which in turn consists of a **lexicon URN** and a **Part-of-Speech Tag** (**POSTag**) documenting one parsing of a Greek morphological form.
- A directory of "editor's indexes", which document human-selected parsings of specific tokens in specific texts, to supplement the machine-parsings and offer disambiguated parsings of as many tokens as possible.


## Expansion of the Generated Data

Much of the work is done programmatically, but there is provision for human editors to make the dataset more accurate and complete.

- The initial processing will result in ambiguous parsings. We will want a mechanism for allowing editorial intervation to disambiguate analyses.
- There is provision for additional index-files, dictionaries of **enclitics**, **anastrophe**, and **elided forms**, and provision for **editor indexes**, files that associates text-token URNs with one-and-only-one "approved" URN-cited item in the **Greek_Morph_Dict**.


## Reference Dictionaries

Some of the files used as reference dictionaries are:

- `source-data/lsj_index.tsv` and `source-data/lsj_index_beta.tsv`. These are indexes to the [CEX version of the LSJ lexicon.](https://github.com/Eumaeus/cite_lsj_cex). **You may choose to edit these! (see below).**
- Dictionaries to help with normalizing Greek. You may add to these.:
	- `source-data/editorial_dict_anastrophe.tsv`
	- `source-data/editorial_dict_elision.tsv`
	- `source-data/editorial_dict_enclitics.tsv`

## Utilities 

There are some utilities for converting text between Unicode and Betacode, and for managing morphological dictionaries:

- Convert a whole text between Unicode and BetaCode: `utilities/`
- Convert one column of a `.tsv` file between Unicode and BetaCode: `utilities/`

## When to Edit the LSJ Indices

The index file to the *LSJ* Index can be a valuable, growing resource for analyzing texts.

Based on the current architecture, the file an editor might consider editing is `source-data/dictionaries/lsj_index_beta.tsv`.

Here's an example:

In the lexicon, `urn:cite2:hmt:lsj.chicago_md:n82662` is the entry for "Περσεφόνη", the goddess, daughter of Demeter. `Περσεφόνη` is the *lemma*. 

But not identified as the *lemma*, yet mentioned in the text of the article, is this: "Ep. Περσεφόνεια". 

So `Περσεφόνεια` is, actually, another lemma for this lexical word.

This is a case for editing the file `source-data/dictionaries/lsj_index_beta.tsv`. 

Where the file has:

	urn:cite2:hmt:lsj.chicago_md:n82662	Persefo/nh	persefonh

We can duplicate that line, and edit it to read:

	urn:cite2:hmt:lsj.chicago_md:n82662	Persefo/neia	persefoneia

Not that the **URN is the same**. We've just added a new *lemma* pointing to that URN.

Now, our automated processes will associate any form produced from `Περσεφόνεια` with the *LSJ* entry for `Περσεφόνη`. 

This is in-line with my epiphane that the *LSJ* Lexicon as printed in the 19th Century is **not a database**. <https://eumaeus.github.io/2018/10/30/lsj.html>. It is not a database, but we can include it in a database.