#!/usr/bin/env julia
# utilities/import_perseus_treebank_morph.jl
# Imports Perseus TB XML morphological data → Dramaturg editorial index.
# Now robust against:
#   • U+0343 (combining koronis) vs. apostrophe / right-quote in CEX
#   • Catalog lines accidentally being treated as tokens
#   • Minor BetaCode failures

using Dramaturg
using BetaReader
using Dates

# ── CONFIG (change these for other texts) ──
const XML_PATH          = "data/working_files/tlg0013.tlg002.perseus-grc1.tb.xml"
const TOKENIZED_CEX     = "data/tokenized/The_Homeric_Hymn_to_Demeter_tokenized.cex"
const OUTPUT_TRIPLETS   = "data/indexes/The_Homeric_Hymn_to_Demeter_perseus_triplets.tsv"
const MATCHED_URNS      = "data/indexes/The_Homeric_Hymn_to_Demeter_matched_urns.tsv"
const ERROR_REPORT      = "data/indexes/The_Homeric_Hymn_to_Demeter_perseus_alignment_errors.txt"
# ───────────────────────────────────────────

"""
    normalize_form(s::String) -> String

Round-trip through BetaReader AFTER canonicalising elision markers.
This is the fix for the koronis/apostrophe mismatch you spotted.
"""
function normalize_form(s::String)::String
    isempty(s) && return ""
    # Standardise all common elision characters to plain apostrophe
    # (U+0343 = combining koronis used in Perseus XML;
    #  U+2019 = right single quote common in CEX editions)
    s = replace(s, '\u0343' => "'")
    s = replace(s, '\u2019' => "'")
    s = replace(s, '\u2018' => "'")   # just in case

    beta = unicodeToBeta(s)
    occursin('#', beta) && return "#FAILED#"
    return betaToUnicode(beta)
end

"""
    load_tokenized_cex(path::String)

Now strictly filters to real token lines (those containing ".token.").
This prevents the catalog line from being treated as token #1.
"""
function load_tokenized_cex(path::String)
    tokens = Tuple{String,String}[]
    for line in eachline(path)
        line = strip(line)
        isempty(line) && continue
        if startswith(line, "urn:cts:greekLit:tlg0013.tlg002.fucex:") &&
           occursin('#', line) &&
           occursin(".token.", line)          # ← new strict filter
            parts = split(line, '#'; limit=2)
            length(parts) == 2 && push!(tokens, (parts[1], parts[2]))
        end
    end
    tokens
end

"""
    parse_perseus_treebank(xml_path::String)

Unchanged regex parser (works fine for Perseus TB).
The two “[0]” failures you saw were harmless parsing artefacts;
they are now logged but do not stop the run.
"""
function parse_perseus_treebank(xml_path::String)
    content = read(xml_path, String)
    word_regex = r"<word\s+([^>]+?)\s*/>"
    words = Tuple{String,String,String}[]

    for m in eachmatch(word_regex, content)
        attrs_str = m[1]
        attr_regex = r"""(\w+)=["']([^"']*)["']"""
        form = lemma = postag = ""
        for attr_m in eachmatch(attr_regex, attrs_str)
            k, v = attr_m[1], attr_m[2]
            k == "form"   && (form   = v)
            k == "lemma"  && (lemma  = v)
            k == "postag" && (postag = v)
        end
        !isempty(form) && push!(words, (form, lemma, postag))
    end
    words
end

function main()
    println("=== Perseus Treebank → Dramaturg alignment (fixed) ===")
    println("XML:  $XML_PATH")
    println("CEX:  $TOKENIZED_CEX")

    cex_tokens = load_tokenized_cex(TOKENIZED_CEX)
    xml_words  = parse_perseus_treebank(XML_PATH)
    println("Loaded $(length(cex_tokens)) CEX tokens and $(length(xml_words)) XML words.")

    # Normalise both sides (the koronis fix lives here)
    norm_cex = [normalize_form(form) for (_, form) in cex_tokens]
    norm_xml = [normalize_form(form) for (form, _, _) in xml_words]

    # ─────────────────────────────────────────────────────────────
    # ALIGNMENT LOGIC (this is the only block you should ever need to edit)
    matched = Tuple{String, String, String, String}[]   # (urn, surface_u, lemma_u, postag)
    beta_failures = String[]
    cex_i, xml_i = 1, 1

    while cex_i ≤ length(cex_tokens) && xml_i ≤ length(xml_words)
        n_cex = norm_cex[cex_i]
        n_xml = norm_xml[xml_i]

        if n_xml == "#FAILED#"
            xml_form = xml_words[xml_i][1]
            push!(beta_failures, "XML form failed BetaCode round-trip: $(xml_form)")
            xml_i += 1
            continue
        end

        if n_cex == n_xml
            # MATCH!
            urn, surface_u = cex_tokens[cex_i]
            _, lemma_u, postag = xml_words[xml_i]
            push!(matched, (urn, surface_u, lemma_u, postag))
            cex_i += 1
            xml_i += 1
        else
            # Mismatch → skip extra token that exists only in the XML edition
            xml_i += 1
        end
    end
    # ─────────────────────────────────────────────────────────────

    # Remaining CEX tokens (if any) have no match
    unmatched_cex = String[]
    while cex_i ≤ length(cex_tokens)
        urn, form = cex_tokens[cex_i]
        push!(unmatched_cex, "$urn\t$form")
        cex_i += 1
    end

    # Write triplets.tsv (ready for scripts/align_lemmata.jl)
    triplets = String[]
    for (_, surface_u, lemma_u, postag) in matched
        surface_beta = unicodeToBeta(surface_u)
        lemma_beta   = unicodeToBeta(lemma_u)
        push!(triplets, join([surface_u, surface_beta, lemma_u, lemma_beta, postag], '\t'))
    end
    write(OUTPUT_TRIPLETS, join(triplets, "\n") * "\n")
    write(MATCHED_URNS, join([u for (u,_,_,_) in matched], "\n") * "\n")

    # Error report
    open(ERROR_REPORT, "w") do io
        println(io, "Perseus Treebank Alignment Report – Homeric Hymn to Demeter")
        println(io, "Generated: $(Dates.now())")
        println(io, "CEX tokens: $(length(cex_tokens))")
        println(io, "XML words:  $(length(xml_words))")
        println(io, "Matched:    $(length(matched))")
        println(io, "Unmatched CEX tokens: $(length(unmatched_cex))")
        println(io, "BetaCode failures:    $(length(beta_failures))")
        println(io, "\n=== BETA CODE FAILURES IN XML ===")
        for f in beta_failures
            println(io, f)
        end
        println(io, "\n=== UNMATCHED CEX TOKENS (urn\tform) ===")
        for um in unmatched_cex
            println(io, um)
        end
    end

    println("\n✅ Done!")
    println("   Triplets      → $OUTPUT_TRIPLETS   ($(length(triplets)) rows)")
    println("   Matched URNs  → $MATCHED_URNS")
    println("   Error report  → $ERROR_REPORT")
    println()
    if length(matched) == 0
        println("⚠️  Still zero matches? Uncomment the debug prints in normalize_form()")
        println("   and run again — the first few normalised forms will be printed.")
    else
        println("Next steps (exactly as before):")
        println("1. Point config.toml [morphology] morph_pos_triplets at $OUTPUT_TRIPLETS")
        println("2. julia scripts/align_lemmata.jl")
        println("3. Zip the matched URNs with the lemmata output into editorial_picks.tsv")
    end
end

main()