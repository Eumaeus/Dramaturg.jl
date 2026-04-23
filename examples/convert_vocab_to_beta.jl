using BetaReader
using Dramaturg  # for get_output_path / config helpers if you want them

# Paths (relative to the script)
vocab_unicode = joinpath(@__DIR__, "..", "data", "vocabulary", "frogs-speech-speaker_vocab.txt")
vocab_beta    = joinpath(@__DIR__, "..", "data", "vocabulary", "frogs-speech-speaker_vocab_beta.txt")

lines = readlines(vocab_unicode)

beta_lines = String[]
for line in lines
    line = strip(line)
    isempty(line) && continue
    if line == "form" || !isnothing(match(r"^[A-Za-zʼʼ]", line))  # keep English header, convert only Greek
        push!(beta_lines, line)
    else
        push!(beta_lines, unicodeToBeta(line))
    end
end

mkpath(dirname(vocab_beta))
write(vocab_beta, join(beta_lines, "\n") * "\n")

println("✅ BetaCode vocabulary ready: $(length(beta_lines)-1) forms → $vocab_beta")