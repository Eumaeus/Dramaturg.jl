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

# Generate clean vocabulary list for the morphological parser
vocab_path = "data/vocabulary/frogs-speech-speaker_vocab.txt"
generate_vocabulary(
    "data/indexes/frogs-speech-speaker_word_histogram.tsv",
    vocab_path
)

println("✅ All indexing complete (with presentation normalization)!")

println("✅ All indexing complete!")