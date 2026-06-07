
# Update all HTML Files


cp scripts/config.toml scripts/backup-config.toml

cp scripts/config-frogs.toml scripts/config.toml
julia --project=. scripts/update_morphology_dictionary.jl

cp scripts/config-demeter.toml scripts/config.toml
julia --project=. scripts/update_morphology_dictionary.jl


cp scripts/config-herodotus.toml scripts/config.toml
julia --project=. scripts/update_morphology_dictionary.jl


cp scripts/config-iliad.toml scripts/config.toml
julia --project=. scripts/update_morphology_dictionary.jl


cp scripts/config-odyssey.toml scripts/config.toml
julia --project=. scripts/update_morphology_dictionary.jl


cp scripts/config-oedipus.toml scripts/config.toml
julia --project=. scripts/update_morphology_dictionary.jl


cp scripts/backup-config.toml scripts/config.toml
rm scripts/backup-config.toml
