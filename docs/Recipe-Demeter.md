# Recipe: *The Homeric Hymn to Demeter*

Using `scripts/config-demeter.toml` as a starting point.

`cd PATH/TO/Dramaturg/`

`cp scripts/config-frogs.toml scripts/config.toml`

`julia --project=. scripts/tokenize_cex.jl`

`cp data/vocabulary/The_Homeric_Hymn_to_Demeter_beta_vocabulary.txt morph/source-data/words.txt`

Start Docker

`docker run --platform linux/amd64 -v /Users/cblackwell/cite/grok/Dramaturg/morph:/morpheus/morph -it perseidsproject/morpheus /bin/bash`

[In the Docker VM terminal] `MORPHLIB=stemlib bin/cruncher -S < morph/source-data/words.txt > morph/output/demeter.txt 2> morph/output/demeter-errors.log`

`julia --project=. scripts/parse_morpheus.jl`

`julia --project=. scripts/align_lemmata.jl`

`julia --project=. scripts/update_morphology_dictionary.jl`
