# Recipe: *The Homeric Hymn to Demeter*

Using `scripts/config-demeter.toml` as a starting point.

	cd PATH/TO/Dramaturg/

	cp scripts/config-demeter.toml scripts/config.toml

	julia --project=. scripts/tokenize_cex.jl

	cp data/vocabulary/The_Homeric_Hymn_to_Demeter_beta_vocabulary.txt morph/source-data/words.txt`

[Start Docker]

	docker run --platform linux/amd64 -v /Users/cblackwell/cite/grok/Dramaturg/morph:/morpheus/morph -it perseidsproject/morpheus /bin/bash

[In the Docker VM terminal] 

	MORPHLIB=stemlib bin/cruncher -S < morph/source-data/words.txt > morph/output/demeter-analysis.txt 2> morph/output/demeter-errors.log

[In the Docker VM terminal] 

	exit

	julia --project=. scripts/parse_morpheus.jl

	julia --project=. scripts/align_lemmata.jl

	julia --project=. scripts/initial_cex.jl

[Optionally]

	julia --project=. scripts/update_morphology_dictionary.jl

	julia --project=. scripts/index_morphology_to_tokens.jl

	julia --project=. -e '
	using Dramaturg
	config = read_config()          # or however your recipe loads the specific config
	chunk_for_html_edition(config)
	'

