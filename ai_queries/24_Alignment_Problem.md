You are helping me with a project to generate thoroughly annotated online texts in Ancient Greek for readers. The project repository is up-to-date at: &lt;https://github.com/Eumaeus/Dramaturg.jl/tree/main&gt;.

In the directory `ai_queries` are enumerated files of the queries that got us to the present state of the project. The output from the current code can be found in the directories `data` and `morph/output`, and for html editions, `editions` (which also includes template files.)

The directory `scripts` contains the scripts that constitute the current pipeline. This pipeline is described in `docs/Pipeline.md`. There are concise "recipes" specific to my three demonstration texts. The current output in `data/` is the result of me walking through each of these recipes.

The scripts of the pipeline depend on Julia code in the `src` directory.

Everything is driven from `scripts/config.toml`.

## Alignment Challenge

I have some legacy data that I would like to use as a editor's index to the Homeric Hymn to Demeter.

An example of such an index, for Aristphanes' Fogs, is on GitHub here:

`source-data/edited_morphology/Aristophanes_Frogs/editorial_picks.tsv`

My edition of the Homeric Hymn to Demeter is here:

`source-data/texts/demeter.cex`

And the scripts you helped me write generate this tokenized edition, with each token cited by CTS-URN:

`data/tokenized/The_Homeric_Hymn_to_Demeter_tokenized.cex`

I have this piece of legacy data, in XML, in which some very good scholars captured morphological and syntactic information for each token of *an edition* of the Homeric Hymn to Demeter:

`data/working_files/tlg0013.tlg002.perseus-grc1.tb.xml`

I am not interested in syntax right now—you helped me get started on a project for documenting Ancient Greek Syntax, which I will return to. But I am interested in a lot of the data in this XML file. Here's one example element:

`&lt;word id="15" form="ἣν" lemma="ὅς" postag="p-s---fa-" relation="OBJ" sg="sbs acc dpd aff" gloss="who" head="20"/&gt;`

We have a surface-form `form`, a lemma, and a POS-tag. Which is all we need to construct a file like this one (which adds beta-code representations of the surface-form and lemma):

	data/indexes/The_Homeric_Hymn_to_Demeter_morpheus_triplets.tsv

But the editors of that XML file did not think to provide citation-information, poetic line. Also, their edition was different from my .cex edition by the presence (in the .cex) of quotation-marks, and some random editorial marks that appear as tokens in one or the other.

I would value your help writing a utility Julia script that does the following:

- Reads in `data/working_files/tlg0013.tlg002.perseus-grc1.tb.xml`.
- Produces something like `data/indexes/The_Homeric_Hymn_to_Demeter_morpheus_triplets.tsv`, which I can then run through the script `scripts/align_lemmata.jl`.
- Using the code in `scripts/align_lemmata.jl`, one way or another, produces a file like `source-data/edited_morphology/Aristophanes_Frogs/editorial_picks.tsv`, which would involve…
- Aligning the tokens in the XML file, and their data, with those in `data/tokenized/The_Homeric_Hymn_to_Demeter_tokenized.cex`.
	- For each token in the .cex file, find the corresponding token in the XML file, and capture its data like an entry in `source-data/edited_morphology/Aristophanes_Frogs/editorial_picks.tsv`, with the correct CTS-URN.
	- If a token in the .cex file cannot be found in the XML, for any reason, skip it.
	- If there are tokens in the XML file that aren't in the CEX file, skip them.
	- It will be necessary to use BetaReader to generate Beta-Code versions of the surface-form and lemma from the XML.
	- For comparison with the tokenized .cex text, it might be bood to "round-trip" unicode Greek in the XML, translating unicode to betacode and back to unicode, as an additional normalization step. 
	- There should be an error report, listing tokens in the .cex file for which there was no match. This error report might also list any Greek forms from the XML that failed BetaCode translation, which would be indicated by the presence of the character '#' in the beta-code output.

The goal will be to have my Dramaturg reading environment provide "Editor's Preferred Parsings" for as many tokens in the Hymn to Demeter as possible, given this legacy XML.

There is a body of similar XML files for other texts, and eventually I would like to take advantage of all of them. Unfortunately, there is *no* consistency in the XML across these files, neither in structure nor in the details of the attributes. 

If you can generate some code for me, and if the block that does the actual alignment-logic is clearly marked, I can educate myself on your code and perhaps be able to handle more of these on my own.

-----

Thanks for this! Unfortunately, it failed to match any tokens in the .cex file with any in the XML.

The file `data/indexes/The_Homeric_Hymn_to_Demeter_perseus_alignment_errors.txt` has been checked into GitHub.

One thing I notice is that the XML, unaccountably, uses a "Greek combining koronis" (U+0343), what I would call a "combinging smooth breathing" as a mark of ellision. The principle of "this character looks kind of like the one I mean, so I'll use it" is rampant among "digital humanities people", alas. Examples:

	form="Δήμητῤ" for "Δήμητρ'"
	form="ἄρχομ̓" for "ἄρχομ'"

My initial reading of the code you gave me, which is checked in at `utilities/import_perseus_treebank_morph.jl`, doesn't reveal what much be a more fundamental problem.

There are probably several reasons, some which I don't see immediately. 

---

Still zero matches, I'm afraid. I couldn't find the lines to un-comment in order to get debug. I've pushed the latest into GitHub.

---

Still no matches. I have checked in the latest code. I'm looking at lines 91 and 92, and also at the output of a little test I added at 106-110. It looks like the variables norm_cex and norm_xml are not actually containing normalized forms?

---

I've added one line in `form_to_beta()`, to correct the idiosyncratic attempt at an ellision following the letter rho, line 33 in the current checked-in version of `utilities/import_perseus_treebank_morph.jl`. This should have been taken care of by the preceding `replace()` functions.

The script is currently matching the first six tokens, and none after that. I'm looking around line 124 in the script. Is it possible that, while it increments `xml_i` to skip an extra token that exists only in XML, it is not incrementing `cex_i` when there is an extra token that exists only in the CEX?

---

I've got it matching up to 459 before failing. The heart of the problem is those crazy ellision marks. I replaced the regex you had given me with the following lines, starting at line 28 in `utilities/import_perseus_treebank_morph.jl`. We don't want to "fix" rho with a combining rough breathing.

~~~
    # Idiosyncratic Perseus rho-elision (Δήμητῤ, etc.)
    # We don't want to replace rho+rough breathing.
    s = replace(s, r"ρ’" => "ρ'")
    s = replace(s, r"ζ̓" => "ζ'")
    s = replace(s, r"σ̓" => "σ'")
    s = replace(s, r"δ̓" => "δ'")
~~~

A regex would obviously be the right answer. But we don't want to catch legitimate smooth-breathings (psili). Just these, which will be over a consonant and at the end of the string.

But also, the script is still not correctly iterating through tokens after errors. It seems that if it hits a mismatch, every subsequent attempt at matching will be off. 

I've checked the current state of the script and its output into GitHub.
