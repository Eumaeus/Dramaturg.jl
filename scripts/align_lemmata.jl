#!/usr/bin/env julia
# scripts/align_lemmata.jl
# Revised 2026-06-07 — efficient Dict-based matching + better normalisation

using Dramaturg
using ArgParse  # kept for future use if you uncomment

"""
    normalize_beta(s::AbstractString; accents::Bool=true, lower::Bool=true)

Normalise a BetaCode lemma for lookup.
- Always strips hyphens.
- Optional lower-casing (covers capitalisation differences).
- Optional accent/dieresis/breathing stripping (fallback level).
"""
function normalize_beta(s::AbstractString; accents::Bool = true, lower::Bool = true)
    t = string(s)
    lower && (t = lowercase(t))
    t = replace(t, "-" => "")
    if !accents
        # Remove: / \ = + (dieresis) ( ) (breathing) * (rough breathing marker)
        t = replace(t, r"[\/\\=+\(\)\*]" => "")
    end
    return t
end

function main()
    config = read_config()
    println("Loaded config for text: ", config["input"]["text_urn"])

    input    = config["morphology"]["morph_pos_triplets"]
    output   = config["morphology"]["morph_lemmata_alignment"]
    errors   = config["morphology"]["morph_lemmata_alignment_errors"]
    lexindex = config["lexicon"]["lsj_index"]          # or config["lexicon"]["lsj_index_beta"] if you prefer

    lex = readlines(lexindex)
    lines = readlines(input)

    # ── Build fast lookup tables once ─────────────────────────────────────
    primary_lookup   = Dict{String, Vector{String}}()   # exact (lower-cased, hyphen-stripped)
    fallback_lookup  = Dict{String, Vector{String}}()   # no accents/dieresis

    for line in lex
        isempty(strip(line)) && continue
        cols = split(line, '\t')
        length(cols) < 2 && continue
        urn  = string(cols[1])
        beta = string(cols[2])

        key_exact = normalize_beta(beta; accents = true, lower = true)
        key_noacc = normalize_beta(beta; accents = false, lower = true)

        get!(Vector{String}, primary_lookup, key_exact) |> (v -> push!(v, urn))
        get!(Vector{String}, fallback_lookup, key_noacc) |> (v -> push!(v, urn))
    end

    println("Built lookup tables from $(length(lex)) LSJ entries ($(length(primary_lookup)) unique primary keys)")

    # ── Process every triplet ─────────────────────────────────────────────
    converted   = String[]
    bad_entries = String[]

    println("Processing $(length(lines)) lines…")
    for (i, line) in enumerate(lines)
        line = strip(line)
        isempty(line) && continue

        parts = split(line, '\t')
        length(parts) < 5 && continue

        lemma_beta = string(parts[4])          # Morpheus lemma (BetaCode)

        # 1. Strip trailing number (e.g. le/gw2 → le/gw, number = "2")
        m = match(r"(.+?)([0-9]+)?$", lemma_beta)
        base_lemma   = m !== nothing ? string(m[1]) : lemma_beta
        lemma_number = m !== nothing && m[2] !== nothing ? m[2] : "1"

        # 2. Try exact match first
        key_exact = normalize_beta(base_lemma; accents = true, lower = true)
        urns = get(primary_lookup, key_exact, String[])

        # 3. Fallback: no accents / dieresis
        if isempty(urns)
            key_noacc = normalize_beta(base_lemma; accents = false, lower = true)
            urns = get(fallback_lookup, key_noacc, String[])
        end

        # 4. Special case you flagged
        if occursin("le/gw", base_lemma)
            filter!(u -> !occursin("n62204", u), urns)   # never choose this one
        end

        if !isempty(urns)
            # Output one line per matching URN (exactly as original behaviour)
            for urn in urns
                new_line = join([
                    parts[1],          # surface Unicode
                    parts[2],          # surface BetaCode
                    parts[3],          # lemma Unicode
                    base_lemma,        # lemma BetaCode (number stripped)
                    urn,               # LSJ URN
                    parts[5]           # POS tag
                ], '\t')
                push!(converted, new_line)
            end
        else
            # Error line (format matches your top-level comment)
            err_line = join([parts[1], base_lemma, "none-found", parts[5]], '\t')
            push!(bad_entries, err_line)
        end

        (i % 1000 == 0) && print(i, " ")
    end

    # ── Write results ─────────────────────────────────────────────────────
    write(output, join(converted, "\n") * (isempty(converted) ? "" : "\n"))
    write(errors, join(bad_entries, "\n") * (isempty(bad_entries) ? "" : "\n"))

    println("\nDone!")
    println("  ✓ $(length(converted)) alignments written to $output")
    println("  ⚠ $(length(bad_entries)) unaligned entries written to $errors")
end

main()