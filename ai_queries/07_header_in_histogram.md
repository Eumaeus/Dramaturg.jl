You are helping me with a project to generate thoroughly annotated online texts in Ancient Greek for readers. The project repository is up-to-date at: <https://github.com/Eumaeus/Dramaturg.jl/tree/main>.

In the directory `ai_queries` are the queries that got us to the present state of the project, including output from the most recent run of the script `examples/tokenize_demo.jl`.

The functions that create `data/indexes/frogs-speech-speaker_word_histogram.tsv` are including as "tokens" each line of the header and catalog from the file `data/tokenized/frogs-speech-speaker_tokenized.cex`. They should work only with data in a `#!ctsdata` block in the CEX file (There may be more than one `#!cexdata` block, with the urn+text lines immediately follwing the `#!ctsdata` header. The current working .cex edition has only one, but the rules for CEX allow more than one.)

We can see this problem in, for example, line 3910 of `data/indexes/frogs-speech-speaker_word_histogram.tsv`, as currently checked into GitHub. This should be a relatively easy fix.

