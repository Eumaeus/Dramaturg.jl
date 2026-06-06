#!/usr/bin/env julia
#=
scripts/index_morphology_to_tokens.jl

Index tokenized CTS-URNs (from the tokenized CEX edition) to
CITE2-URNs in the master morphology dictionary.

Matches on normalized surface forms (grave accents are converted
to acute accents to align with the normalization used in
Greek_Morphology.cex).

- One-to-one or one-to-many associations are written to the index.
- Punctuation tokens are silently skipped.
- Elided forms listed in editorial_dict_elision.tsv (surface_form → expanded_form)
  are automatically resolved to their expanded form and matched to morphology
  entries before any error is logged.
- Any remaining non-punctuation token without a matching morphology entry
  is logged to the error file (for transliteration issues, missing forms, etc.).

Usage (run from project root):
    julia --project=. scripts/index_morphology_to_tokens.jl

The script uses the current config.toml (via src/config.jl)
exactly as requested in the project milestone.
=#

using Dramaturg
using Unicode

# ----------------------------------------------------------------------
# Load configuration (exactly as specified)
# ----------------------------------------------------------------------
config = read_config()
println("Loaded config for text: ", config["input"]["text_urn"])

morph_path   = config["editorial"]["master_morph_dict"]
tokenized_path = get_output_path(config, "tokenized")
output_path  = config["morphology"]["morph_token_index"]
errors_path  = config["morphology"]["morph_token_index_errors"]

println("Morphology dictionary: $morph_path")
println("Tokenized edition:     $tokenized_path")
println("Output index:          $output_path")
println("Error log:             $errors_path")

# ----------------------------------------------------------------------
# Helper: normalize surface form (grave → acute)
# This matches the normalization used in Greek_Morphology.cex.
# Works on both precomposed and combining accents.
# ----------------------------------------------------------------------
function normalize_surface(s::AbstractString)::String
    # Decompose so diacritics are separate
    nfd = Unicode.normalize(s, :NFD)
    # Grave (U+0300) → acute (U+0301)
    normalized = replace(nfd, '\u0300' => '\u0301')
    # Recompose to canonical form
    return Unicode.normalize(normalized, :NFC)
end

# ----------------------------------------------------------------------
# 1. Build morphology lookup: normalized uc_form → list of CITE2 URNs
# ----------------------------------------------------------------------
morph_dict = Dict{String, Vector{String}}()

morph_lines = readlines(morph_path)
skipped = 0
for line in morph_lines
    line = strip(line)
    if isempty(line) ||
       startswith(line, "#!") ||
       startswith(line, "//") ||
       startswith(line, "urn#desc") ||
       !startswith(line, "urn:cite2:fufolio:greekmorph")
       global skipped += 1
        continue
    end

    parts = split(line, '#')
    if length(parts) < 3
        continue
    end

    morph_urn = strip(parts[1])
    uc_form   = strip(parts[3])          # canonical surface form (field 3)

    norm_form = normalize_surface(uc_form)

    if !haskey(morph_dict, norm_form)
        morph_dict[norm_form] = String[]
    end
    push!(morph_dict[norm_form], morph_urn)
end

println("Loaded $(length(morph_dict)) unique normalized surface forms from the morphology dictionary (skipped $skipped header/comment lines).")

# ----------------------------------------------------------------------
# 1b. Load elision dictionary: normalized surface_form → normalized expanded_form
# ----------------------------------------------------------------------
elision_path = "source-data/dictionaries/editorial_dict_elision.tsv"
elision_to_expanded = Dict{String, String}()

elision_lines = readlines(elision_path)
for line in elision_lines
    line = strip(line)
    if isempty(line) || startswith(line, "surface_form")
        continue
    end

    parts = split(line, '\t')
    if length(parts) >= 2
        surf = strip(parts[1])
        expd = strip(parts[2])
        norm_surf = normalize_surface(surf)
        norm_expd = normalize_surface(expd)
        elision_to_expanded[norm_surf] = norm_expd
    end
end

println("Loaded $(length(elision_to_expanded)) elision mappings from $elision_path.")

# ----------------------------------------------------------------------
# 2. Process tokenized text and build index + error list
# ----------------------------------------------------------------------
index_entries   = String[]
error_entries   = String[]
elided_resolved = 0

token_lines = readlines(tokenized_path)
for line in token_lines
    line = strip(line)
    if isempty(line) || !occursin('#', line)
        continue
    end

    parts = split(line, '#')
    if length(parts) < 2
        continue
    end

    token_urn = strip(parts[1])
    surface   = strip(parts[2])

    norm_surface = normalize_surface(surface)

    if haskey(morph_dict, norm_surface)
        # One-to-many possible
        for murn in morph_dict[norm_surface]
            push!(index_entries, "$(token_urn)\t$(murn)")
        end
    else
        # Punctuation check: no Unicode letters → skip silently
        if !occursin(r"\p{L}", surface)
            continue
        else
            # NEW: try resolving via elision dictionary first
            if haskey(elision_to_expanded, norm_surface)
                expanded_norm = elision_to_expanded[norm_surface]
                if haskey(morph_dict, expanded_norm)
                    for murn in morph_dict[expanded_norm]
                        push!(index_entries, "$(token_urn)\t$(murn)")
                    end
                    global elided_resolved += 1
                    continue  # resolved successfully → no error
                end
            end
            # If we reach here, it was neither a direct match nor a successfully resolved elision
            push!(error_entries,
                  "$(token_urn)\t$(surface)\t$(norm_surface)\tno_match_in_morph_dict")
        end
    end
end

# ----------------------------------------------------------------------
# 3. Write outputs
# ----------------------------------------------------------------------
# Index (TSV, one entry per association, sorted by token URN)
if !isempty(index_entries)
    sort!(index_entries)
    open(output_path, "w") do io
        for entry in index_entries
            println(io, entry)
        end
    end
    println("Wrote $(length(index_entries)) index entries → $output_path")
else
    println("No index entries generated!")
end

println("Resolved $elided_resolved elided forms using the editorial dictionary.")

# Errors (TSV with header for easy inspection)
if !isempty(error_entries)
    open(errors_path, "w") do io
        println(io, "token_urn\tsurface_form\tnormalized_form\treason")
        for entry in error_entries
            println(io, entry)
        end
    end
    println("Found $(length(error_entries)) unmatched non-punctuation tokens → $errors_path")
    println("   (Elided forms were automatically resolved where possible using source-data/dictionaries/editorial_dict_elision.tsv)")
else
    println("No errors! All non-punctuation tokens matched a morphology entry.")
end

println("\nMorphology-to-tokens indexing complete! ")
println("You can now proceed to generate reader editions and further analyses.")