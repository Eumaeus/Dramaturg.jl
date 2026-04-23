using TOML

"""
    read_config(path::String = "examples/config.toml")
Load and return the TOML configuration as a Dict.
"""
function read_config(path::String = joinpath(@__DIR__, "..", "examples", "config.toml"))
    if !isfile(path)
        error("Config file not found: $path")
    end
    return TOML.parsefile(path)
end

"""
    get_output_path(config::Dict, key::String)
Auto-generates a tidy, readable output path using the input text_URN or filename from config.toml.
"""
function get_output_path(config::Dict, key::String)
    data_root = config["processing"]["data_root"]
    text_id = split(config["input"]["text_urn"], ':')[end] |> 
              x -> replace(x, r"[^a-zA-Z0-9]" => "_")
    if isempty(text_id)
        text_id = splitext(basename(config["input"]["file_name"]))[1]
    end

    if key == "tokenized"
        dir = joinpath(data_root, config["processing"]["tokenized_dir"])
        return joinpath(dir, text_id * config["processing"]["tokenized_suffix"])

    elseif key == "elided_index"
        dir = joinpath(data_root, config["processing"]["indexes_dir"])
        return joinpath(dir, text_id * config["processing"]["elided_index_suffix"])

    elseif key == "elided_histogram"
        dir = joinpath(data_root, config["processing"]["indexes_dir"])
        return joinpath(dir, text_id * config["processing"]["elided_histogram_suffix"])

    elseif key == "word_histogram"
        dir = joinpath(data_root, config["processing"]["indexes_dir"])
        return joinpath(dir, text_id * config["processing"]["word_histogram_suffix"])

    elseif key == "vocabulary_unicode"
        dir = joinpath(data_root, config["processing"]["vocabulary_dir"])
        return joinpath(dir, text_id * config["processing"]["vocabulary_unicode_suffix"])

    elseif key == "vocabulary_beta"
        dir = joinpath(data_root, config["processing"]["vocabulary_dir"])
        return joinpath(dir, text_id * config["processing"]["vocabulary_beta_suffix"])

    end
    error("Unknown output key: $key")
end