# Recipe: Euripides' *The Phoenician Women*

Using `scripts/config-euripides_phoenician.toml` as a starting point.

cd PATH/TO/Dramaturg/

[Start Docker]

cp scripts/Configs_Euripides/config-euripides_phoenician.toml scripts/config.toml

julia --project=. scripts/tokenize_cex.jl

cp data/vocabulary/Euripides_Phoenician/Euripides_Phoenician_beta_vocabulary.txt morph/source-data/words.txt

docker run --platform linux/amd64 -v /Users/cblackwell/cite/grok/Dramaturg/morph:/morpheus/morph -it perseidsproject/morpheus /bin/bash

[In the Docker VM terminal] 

MORPHLIB=stemlib bin/cruncher -S < morph/source-data/words.txt > morph/output/euripides-phoenician-analysis.txt 2> morph/output/euripides-phoenician-errors.log

exit

[Back in the host computer]

julia --project=. scripts/parse_morpheus.jl

julia --project=. scripts/align_lemmata.jl

julia --project=. scripts/initial_cex.jl

julia --project=. scripts/update_morphology_dictionary.jl

julia --project=. scripts/index_morphology_to_tokens.jl

julia --project=. scripts/generate_html_index.jl

julia --project=. scripts/generate_html_reader_pages.jl	
