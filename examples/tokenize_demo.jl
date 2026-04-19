using Dramaturg

config = read_config()
println("Loaded config for text: ", config["input"]["text_urn"])

cex_data = load_cex(config["input"]["cex_path"])

tokenized_data = tokenize_to_exemplar(cex_data, config)
# Pass the original CEX path so we can preserve its metadata blocks
tokenized_path = write_tokenized_cex(config["input"]["cex_path"], tokenized_data, config)

generate_elision_index(cex_data, read(tokenized_path, String), config)