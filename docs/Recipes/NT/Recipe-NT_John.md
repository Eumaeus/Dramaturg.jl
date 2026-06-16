# Recipe: NT John

Using `scripts/config-nt-john.toml` as a starting point.

cd PATH/TO/Dramaturg/

[Start Docker]

cp scripts/Configs/NT/config-nt-john.toml scripts/config.toml

julia --project=. scripts/tokenize_cex.jl

cp data/vocabulary/NT/John/John_beta_vocabulary.txt morph/source-data/words.txt

docker run --platform linux/amd64 -v /Users/cblackwell/cite/grok/Dramaturg/morph:/morpheus/morph -it perseidsproject/morpheus /bin/bash

[In the Docker VM terminal] 

MORPHLIB=stemlib bin/cruncher -S < morph/source-data/words.txt > morph/output/nt-john-analysis.txt 2> morph/output/nt-john-errors.log

exit

[Back in the host computer]

julia --project=. scripts/parse_morpheus.jl

julia --project=. scripts/align_lemmata.jl

julia --project=. scripts/initial_cex.jl

cp scripts/Configs/NT/config-nt-john.toml scripts/config.toml

julia --project=. scripts/update_morphology_dictionary.jl

julia --project=. scripts/index_morphology_to_tokens.jl

julia --project=. scripts/generate_html_index.jl

julia --project=. scripts/generate_html_reader_pages.jl	

