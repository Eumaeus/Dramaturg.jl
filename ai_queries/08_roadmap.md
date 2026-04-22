You are helping me with a project to generate thoroughly annotated online texts in Ancient Greek for readers. The project repository is up-to-date at: <https://github.com/Eumaeus/Dramaturg.jl/tree/main>.

In the directory `ai_queries` are the queries that got us to the present state of the project, including output from the most recent run of the script `examples/tokenize_demo.jl`.

For the record, and mainly for my own thoughts, I want to outline the roadmap for the project, as I currently see it.

At the moment, none of these are items for immediate action. 

### General Overview

The library will serve several related functions, when complete:

1. Tools for normalizing, tokenizing, and indexing texts. The input will be texts cited by CTS-URN serialized as CEX libraries, **and** CITE collections, cited by CITE2-URN, also serialized as CEX libraries. The output will be CEX libraries, `.tsv` files, or plain text. The current file `examples/tokenize_demo.jl` would be the ideal basis for a unified `index_text()` function.
1. Tools for capturing and serializing morphological data, keyed to the CITE2-URNs of the [CITE version of the LSJ lexicon](https://github.com/Eumaeus/LSJ.js/blob/main/data/index.txt). Output will be CITE collections, cited by CITE2 URN, serialized as CEX libraries. I imagine a script with its own `config.toml` called `parse_and_align()`, or something like that. It would do two things:
	- Generate (and subsequently update and expand) a CITE-collection of "unique parsed forms", each citable by CITE2 URN. Once we have parsed `ἀνθρώποις` and concluded that it is "from `ἄνθρωπος` [urn:cite2:hmt:lsj.chicago_md:n8909]: noun, masculine, dative, plural" *an nothing else*, we might as well record that collection of data as an object with a URN, and any subsequent instances of `ἀνθρώποις` can cite it by URN. When there is more than one possible parsing, a single surface form will appear in more than one object in the collection, but each paing of surface-form, morphological parsing, and citation to the lexicon will be unique. When a new text is to be parsed, surface-forms can be checked against that master CITE collection, and added only if they are not already present.
	- Generate a text-specific collection of morphology and lexicography. Token-level CTS-URNs pointing to an instance of a word in the text, associated with CITE2 URNs from the master list. One CTS-URN may have several possible parsings. So we would have a CITE collection of "parsed-tokens", each with a CITE2 URN, and each having at least two fields: token-level CTS-URN and CITE2 URN to a unique parsed form.
	- Generate a log of problems and errors in parsing or alignment that require editorial intervention. Allow some mechanism to capture, where possible, solutions to those problems for the future. This will not always be possible, of course.
1. Tools for generating reader-friendly HTML editions of Greek texts, with navigation among pages and low-friction access to morphological and lexical information for each word, and other editorially supplied commentary.
	- An attracive display of the text, paged into reasonable chunks, with navigation from page to page.
	- If possible, a "hover" feature to reveal morphological and lexical information for each word. 
	- Indication of where there is some editorial comment.
	- Ubiquitous links to a local copy of the HTML-JS LSL lexicon.
1. Some pipeline and UI to allow an editor to enhance the text by disambiguating morphological and lexical information. 
1. Tools for generating elegant printable texts via $\LaTeX$, *vel sim.*l

### Steps

The following is me thinking aloud, based on the above *desiderata*. As the project moves forward, I expect the sequence and details will evolve. There will be subsequent versions of this document.

- In addition to, *e.g.* `data/indexes/frogs-speech-speaker_word_histogram.tsv`, I would like to generate one more file: `data/indexes/frogs-speech-speaker_vocabulary.txt`. This would be a plain listing of the words in the histogram (which are in their unelided and normalized, "presentational" forms.)
- I need to document in this project the workflow for feeding a list of vocabulary to the `morpheus` service (which runs in a Docker container), generating the kind of data you were helping me with at <.https://github.com/Eumaeus/pos-julia>.
- I would like to move the functionality at <https://github.com/Eumaeus/pos-julia> over to this project, in some clean way. Since that project is very much unfinished, it seems to make more sense to move it, and build it up here.
- The project at <https://github.com/Eumaeus/pos-julia> reads `morpheus` output and generates POS-Tags + lexicon-lemmata describing each part-of-speech. I would like to have a function that translates POS-tags to human-readable descriptions, *e.g.* "from ἄνθρωπος: noun, masculine, nominative, singular" or "from λύω: verb, imperfect, active, indicative, 3rd person, plural."
- The aim of the previous items is to generate a file that contains morphological and lexical information for every word-token in the text.
- I want to move a copy of <https://github.com/Eumaeus/LSJ.js> into this project, so eventually a generated text will include all the HTML files for the text and a local copy of the lexicon app.
- Using the lexicon's index file at <https://github.com/Eumaeus/LSJ.js/blob/main/data/index.txt>, I want to align the lemmata (headwords) provided by Morpheus with cite2-urns in the lexicon. This will require some manual editorial intervention, certainly.
- There will be tokens that do not resolve using the morphological parser and lexicon, clearly. But I would like every token to be accounted for in some way. So I would like to generate an index, based on the tokenized-cex and its CTS-URNs, that categorizes each token thus (some of this can be automated, and some will require human editing; the play *Frogs* will not have every category represented, I think.):
	- punctuation
	- lexical word
	- named-entity
	- word-fragment
	- onomatopoeia
	- numeral
	- editorial-sign
- There are hyphenated words in *Frogs*, either metrical enjambment or when one character interrupts another. I would like to index those instances (both the fragment before and after the hyphen) to a complete word, with its parsing. We don't want to mess with the text, but if there is a word split across a line (lines 391-392: `εἰ-πεῖν`), when the text is presented online, I would like for a user to click/hover on either `εἰ-` or `πεῖν` and get information for `εἰπεῖν`. These should be easy to spot: hyphens as the last character of a line.
- (These hyphenated words are not "word-fragments", really. A "word-fragment" would be when a text says something like "It is thus with all words ending in 'ης'.")
- **When all this works** it will be time to think about user-interface.
- I want two versions of a UI:
	- One for readers, along the lines of: <https://github.com/Eumaeus/Oedipus_2019>.
	- One for editors (me). This might be best as a Dash project, because I want to read the text, seeing the suggested parsing and lexicon entries for words, and picking the correct one for each context, and saving that information as yet another index. So if `ἔργα` is parsed as either "neuter nominative plural" or "neuter accusative plural", I want to identify "neuter accusative plural" as the correct description for a particular occurance of the word in context. Likewise, there are three lexicon entries for the verb `δέω`, and I would like to pick the one that applies to a particular context. The resulting index will serve to inform the construction of the Reader UI.
- I would like to be able to add CEX files of commentaries, keyed to the text by URN. This will be especially helpful in the case of tokens that are named-entities (often not present in the lexicon, and often needing disambiguation and explanation). But the comments should be able to apply to a line, a range of lines, a single token, or a range of tokens. 
