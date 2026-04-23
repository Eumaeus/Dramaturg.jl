using BetaReader


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

"""
    unicode_to_beta_file(input_path::String, output_path::String)
Convenience wrapper around BetaReader.unicodeToBeta for whole files.
"""


"""
    unicode_to_beta_file(input_path::String, output_path::String)

Convert a Unicode Greek text file (vocabulary list or full text, one entry per line)
to BetaCode. English header lines (e.g. "form") are left unchanged.
"""
function unicode_to_beta_file(input_path::String, output_path::String)
    lines = readlines(input_path)
    converted = String[]

    for line in lines
        stripped = strip(line)
        safestring = replace(stripped, "ʼ" => s"'") # fix elision marks
        isempty(safestring) && continue

        # Preserve obvious non-Greek header lines
        if safestring == "form" || !contains_greek(safestring)
            push!(converted, safestring)
        else
            push!(converted, unicodeToBeta(safestring))
        end
    end

    mkpath(dirname(output_path))
    write(output_path, join(converted, "\n") * "\n")

    println("✅ Unicode → BetaCode: $(length(converted)) forms → $output_path")
    return output_path
end


"""
    beta_to_unicode_file(input_path::String, output_path::String)

Convert a BetaCode text file back to normalized Unicode Greek.
"""
function beta_to_unicode_file(input_path::String, output_path::String)
    lines = readlines(input_path)
    converted = String[]

    for line in lines
        stripped = strip(line)
        isempty(stripped) && continue
        push!(converted, betaToUnicode(stripped))
    end

    mkpath(dirname(output_path))
    write(output_path, join(converted, "\n") * "\n")

    println("✅ BetaCode → Unicode: $(length(converted)) lines → $output_path")
    return output_path
end


"""
    contains_greek(s::AbstractString) -> Bool

Simple heuristic to detect Greek characters (used to protect English headers).
"""
function contains_greek(s::AbstractString)
    any(c -> ('α' ≤ c ≤ 'ω') || ('Α' ≤ c ≤ 'Ω'), s)
end