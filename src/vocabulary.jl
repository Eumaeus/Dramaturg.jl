"""
    generate_vocabulary(histogram_path::String, vocab_path::String)
Create a plain-text vocabulary file (one normalized form per line)
from a word-histogram TSV. Punctuation tokens are omitted.
The histogram is assumed to have no header row.
"""
function generate_vocabulary(histogram_path::String, vocab_path::String)
    vocab = String[]
    for line in eachline(histogram_path)
        isempty(strip(line)) && continue
        cols = split(line, '\t')
        length(cols) >= 2 || continue
        form = strip(cols[2])
        if !isempty(form) && !is_punctuation(form)
            push!(vocab, form)
        end
    end

    # The histogram already contains unique forms, but we sort for nice human-readable output
    sort!(vocab)

    mkpath(dirname(vocab_path))  # create data/vocabulary/ if it doesn't exist
    write(vocab_path, join(vocab, "\n") * "\n")

    n = length(vocab)
    println("✅ Vocabulary list generated: $n forms → $vocab_path")
    return n
end