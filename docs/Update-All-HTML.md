
# Update all HTML Files


cp scripts/config.toml scripts/backup-config.toml


cp scripts/Configs/Homer/config-hymn-2-Demeter.toml scripts/config.toml
julia --project=. scripts/index_morphology_to_tokens.jl
julia --project=. scripts/generate_html_index.jl
julia --project=. scripts/generate_html_reader_pages.jl	



cp scripts/backup-config.toml scripts/config.toml
rm scripts/backup-config.toml
