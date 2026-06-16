# Recipe: Sophocles' *Ajax*

Using `scripts/Configs/Sophocles/config-sophocles-ajax.toml` as a starting point.

cd PATH/TO/Dramaturg/

[Start Docker]

cp scripts/Configs/Sophocles/config-sophocles-ajax.toml scripts/config.toml

julia --project=. scripts/tokenize_cex.jl

cp data/vocabulary/Sophocles/Ajax/Ajax_beta_vocabulary.txt morph/source-data/words.txt

docker run --platform linux/amd64 -v /Users/cblackwell/cite/grok/Dramaturg/morph:/morpheus/morph -it perseidsproject/morpheus /bin/bash

[In the Docker VM terminal] 

MORPHLIB=stemlib bin/cruncher -S < morph/source-data/words.txt > morph/output/ajax-analysis.txt 2> morph/output/ajax-errors.log

exit

[Back in the host computer]

julia --project=. scripts/parse_morpheus.jl

julia --project=. scripts/align_lemmata.jl

julia --project=. scripts/initial_cex.jl

julia --project=. scripts/update_morphology_dictionary.jl

cp scripts/Configs/Sophocles/config-sophocles-ajax.toml scripts/config.toml

julia --project=. scripts/index_morphology_to_tokens.jl

julia --project=. scripts/generate_html_index.jl

julia --project=. scripts/generate_html_reader_pages.jl	
