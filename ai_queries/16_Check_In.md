You are helping me with a project to generate thoroughly annotated online texts in Ancient Greek for readers. The project repository is up-to-date at: <https://github.com/Eumaeus/Dramaturg.jl/tree/main>.

In the directory `ai_queries` are the queries that got us to the present state of the project. The output from the current code can be found in the directories `data` and `morph/output`.

## Background

Thanks to your help, I am much farther along. I was on a month-long trip to the Khumbu Valley of Nepal and had to do some coding on my own… old school!

The current state of the project is checked into GitHub. 

The most useful file, for you, is: `docs/Pipeline.md`.

I have also written a (very preliminary, very disorganized) overview at: `docs/Architecture.md`

## Current Requests

**1.** I would value your professional eye on the work to date, and suggestions for refactoring, efficiency, etc.

**2.** I can currently generate text-specific files like: `data/indexes/The_Homeric_Hymn_to_Demeter_triplets_lemmata.tsv`.

> The "triplets" have expanded "sextets": a surface-form in unicode and betacode, a lemma in both unicode and betacode, a URN to the LSJ lexicon, and a part-of-speech-tag. The combination of surface-form, lemma, LSJ URN, and POStag will define "uniqueness".

This is great, but the point of the whole project is to simplify Ancient Greek philology by taking expensive, imprecise computational processes and reducing them to simplie URN-to-URN look-ups. So those "triplets" should be citable by URN.

So they should be part of a CITE Collection, citable by CITE2-URNs, serialized as a `.cex` file, called `Greek_Morphology.cex`. It will be an unordered collection.

So… I would like to have a master morphology dictionary, `source-data/dictionaries/Greek_Morphology.cex` (This is identified in `scripts/config.toml`). 

I have written the skeleton `source-data/dictionaries/Greek_Morphology.cex`, defining the CITE collection and the properties of objects in it. I would like help populating this initial collection from the data it `data/indexes/The_Homeric_Hymn_to_Demeter_triplets_lemmata.tsv`. 

In file `source-data/dictionaries/Greek_Morphology.cex`, lines 23-32 define the properties of objects in the collection. There are eight:

1. `urn`: This will be a Cite2Urn uniquely identifying each object (morphological form) in this collection, *e.g.* `urn:cite2:fufolio:greekmorph.2026a:20260601T082422479`. `urn:cite2:` establishes the type and namespace of the URN. `greekmorph.2026a` is the `2026a` *version* of the collection named `greekmorph`. `20260601T082422479` is an arbitray object-identifier. (I generated that using Julia's `today()` function, stripping punctuation; as I process other texts, Aristophanes' *Frogs*, Herodotus, I want to add new forms to this collection, and a date-time-based identifier seems the easiest way to ensure uniqueness.)

2. `desc`: This is the "labelling property" (see lines 17-18 of the CEX file). This should be a human-readable label for the object. See below.

3. `uc_form` and `bc_form` are unicode and betacode representations of the surface form. These are columns 1 and 2 of `data/indexes/The_Homeric_Hymn_to_Demeter_triplets_lemmata.tsv`.

4. `uc_lemma` and `bc_lemma` are unicode and betacode representations of the lemma from which the surface form is derived. These are columns 3 and 4 of `data/indexes/The_Homeric_Hymn_to_Demeter_triplets_lemmata.tsv`.

5. `lsj`: This is the Cite2Urn to an entry in the LSJ lexicon. See `source-data/dictionaries/lsj_chicago.cex`. These are at column 5 of `data/indexes/The_Homeric_Hymn_to_Demeter_triplets_lemmata.tsv`.

6. `pos`: This is the POS-tag, column 6 of `data/indexes/The_Homeric_Hymn_to_Demeter_triplets_lemmata.tsv`.

**The `desc` property:**

This should be generated from the data, using the function `describe_pos()` in the source file `src/morphology.jl`, with the addition of the LSJ URN. An example would look like this:

> **λύσω**. From **λύω**. Verb. Aorist, subjunctive, active, 1st person, singular. [v1sasa---]. See `urn:cite2:hmt:lsj.chicago_md:n64316`.

A complete entry, inserted into `source-data/dictionaries/Greek_Morphology.cex` after line 35, would look like this:

~~~
urn:cite2:fufolio:greekmorph.2026a:20260601T082422479#**λύσω**. From **λύω**. Verb. Aorist, subjunctive, active, 1st person, singular. [v1sasa---]. See `urn:cite2:hmt:lsj.chicago_md:n64316`.#λύσω#lu/sw#λύω#lu/w#urn:cite2:hmt:lsj.chicago_md:n64316#v1sasa---
~~~

## Summary

- I would your help with one script that will populate `source-data/dictionaries/Greek_Morphology.cex` with CITE Collection Objects, using the data in `data/indexes/The_Homeric_Hymn_to_Demeter_triplets_lemmata.tsv`, with generated CITE2URNs for each object, and a generated `desc` property using the function `describe_pos()` to generate a human-readable label for the object.

**The next step after this…**

Let's do the above first, but the next step will be for me to run these processes (described in `docs/Pipeline.md`) on Aristophanes' *Frogs* and then on Herodotus, and further populate my growing CITE Collection of Greek morphological forms:

- **Next Step**: I would like help with another script that will take a subsequent file *like* `data/indexes/The_Homeric_Hymn_to_Demeter_triplets_lemmata.tsv`, and add to `source-data/dictionaries/Greek_Morphology.cex` any forms that are not already present, ensuring that no to citable objects in the collection have the same combination of surface-form, lemma, LSJ URN, and pos-tag. 









