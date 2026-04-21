using Dramaturg

config = read_config()
println("Loaded config for text: ", config["input"]["text_urn"])

cex_data = load_cex(config["input"]["cex_path"])

tokenized_data = tokenize_to_exemplar(cex_data, config)
tokenized_path = write_tokenized_cex(config["input"]["cex_path"], tokenized_data, config)

tokenized_cex_str = read(tokenized_path, String)

generate_elision_index(cex_data, tokenized_cex_str, config)

# NEW: full vocabulary histogram (uses editorial expansions where available)
generate_word_histogram(tokenized_cex_str, config)

println("✅ All indexing complete!")