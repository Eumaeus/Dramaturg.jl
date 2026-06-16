# Recipe: Aristophanes' *Wasps*

Using `scripts/Configs/Aristophanes/config-wasps.toml` as a starting point.

cd PATH/TO/Dramaturg/

[Start Docker]

cp scripts/Configs/Aristophanes/config-wasps.toml scripts/config.toml

julia --project=. scripts/tokenize_cex.jl

cp data/vocabulary/Aristophanes/Wasps/Aristophanes_Wasps_beta_vocabulary.txt morph/source-data/words.txt

docker run --platform linux/amd64 -v /Users/cblackwell/cite/grok/Dramaturg/morph:/morpheus/morph -it perseidsproject/morpheus /bin/bash

[In the Docker VM terminal] 

MORPHLIB=stemlib bin/cruncher -S < morph/source-data/words.txt > morph/output/aristophanes-wasps-analysis.txt 2> morph/output/aristophanes-wasps-errors.log

exit

[Back in the host computer]

julia --project=. scripts/parse_morpheus.jl

julia --project=. scripts/align_lemmata.jl

julia --project=. scripts/initial_cex.jl

julia --project=. scripts/update_morphology_dictionary.jl

julia --project=. scripts/index_morphology_to_tokens.jl

julia --project=. scripts/generate_html_index.jl

julia --project=. scripts/generate_html_reader_pages.jl	
