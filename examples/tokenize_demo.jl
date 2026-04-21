using Dramaturg
using Unicode

config = read_config()
println("Loaded config for text: ", config["input"]["text_urn"])

cex_data = load_cex(config["input"]["cex_path"])

tokenized_data = tokenize_to_exemplar(cex_data, config)
tokenized_path = write_tokenized_cex(config["input"]["cex_path"], tokenized_data, config)

tokenized_cex_str = read(tokenized_path, String)

generate_elision_index(cex_data, tokenized_cex_str, config)


generate_elision_index(cex_data, read(tokenized_path, String), config)
generate_word_histogram(read(tokenized_path, String), config)   # ← already there, now enhanced

println("✅ All indexing complete (with presentation normalization)!")

println("✅ All indexing complete!")