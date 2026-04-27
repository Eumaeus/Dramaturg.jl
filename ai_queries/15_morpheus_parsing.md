You are helping me with a project to generate thoroughly annotated online texts in Ancient Greek for readers. The project repository is up-to-date at: <https://github.com/Eumaeus/Dramaturg.jl/tree/main>.

In the directory `ai_queries` are the queries that got us to the present state of the project. The output from the current code can be found in the directories `data` and `morph/output`.

## Updates

I have been making unit-tests for:

- Conversion of Morpheus-output to Perseus-style POS tags. The code for that is `src/morphology.jl`
- Conversion of POS-tags to human-readable descriptions. That code is also in `src/morphology.jl`


## Requests for Help

I would like to refactor the function `parse_morpheus_to_triplets` in `src/morphology.jl`. Currently, it does a lot of things:

- Reads in source-data.
- Sets up output filepaths.
- Iterates through the lines in the source.
- Strips out the surface-forms into variable `surface`
- Gets all subsequent `<NL>` elements.
- Processes the `surface` and `<NL>` elements associated with one `surface`.
- Serializes them as triplets.

I would like to refactor this so that once we have a `surface` and a block of `<NL>` elements, those are passed off to another function for decoding into POS tags. 

This would make debugging easier.

And while we're looking at that code, here's one bug we can address.

In the file `morph/output/analysis.txt`, current checked into GitHub, at lines 3145–3146, we see a surface form `poiw=n`, and among its associated `<NL>` parsings, we see:

`<NL>P poie/w  pres part act masc nom sg	attic epic doric	contr	ew_pr,ew_denom</NL>`

This is a "verb, present participle active masculine nominative singular". The correct POS-tag should be: `v-sppamn-`

The current code is producing the triplet: `poiw=n	poie/w	v-sppamn-`.

So, I would value any help and advice with this! Thanks!
