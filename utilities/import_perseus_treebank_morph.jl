#!/usr/bin/env julia
# scripts/import_perseus_treebank_morph.jl
# Imports Perseus TB XML morphological data and aligns it to your tokenized CEX edition.
# Produces a Morpheus-style triplets file + matched URNs + error report.

using Dramaturg    # pulls in BetaReader automatically
using BetaReader
using Dates

# ── CONFIG (edit these paths if you want to reuse the script for other texts) ──
const XML_PATH          = "data/working_files/tlg0013.tlg002.perseus-grc1.tb.xml"
const TOKENIZED_CEX     = "data/tokenized/The_Homeric_Hymn_to_Demeter_tokenized.cex"
const OUTPUT_TRIPLETS   = "data/indexes/The_Homeric_Hymn_to_Demeter_perseus_triplets.tsv"
const MATCHED_URNS      = "data/indexes/The_Homeric_Hymn_to_Demeter_matched_urns.tsv"
const ERROR_REPORT      = "data/indexes/The_Homeric_Hymn_to_Demeter_perseus_alignment_errors.txt"
# ─────────────────────────────────────────────────────────────────────────────

"""
    normalize_form(s::String) -> String

Round-trip through BetaReader for canonical normalisation.
Returns "#FAILED#" (and logs it) if BetaCode conversion produces '#'.
"""
function normalize_form(s::String)::String
    isempty(s) && return ""
    #println("normalizing: $s")
    beta = unicodeToBeta(s)
    #println("got: $beta\n")
    occursin('#', beta) && return "#FAILED#"
    return betaToUnicode(beta)
end

"""
    load_tokenized_cex(path::String)

Returns vector of (urn, surface_unicode) for every token line.
"""
function load_tokenized_cex(path::String)
    tokens = Tuple{String,String}[]
    for line in eachline(path)
        line = strip(line)
        isempty(line) && continue
        # Only data lines from the Hymn to Demeter tokenized edition
        if startswith(line, "urn:cts:greekLit:tlg0013.tlg002.fucex:") && occursin('#', line)
            parts = split(line, '#'; limit=2)
            length(parts) == 2 && push!(tokens, (parts[1], parts[2]))
        end
    end
    tokens
end

"""
    parse_perseus_treebank(xml_path::String)

Simple regex parser for the flat <word ... /> elements in Perseus treebanks.
Extracts form, lemma, postag. Works for the standard Perseus TB XML structure.
"""
function parse_perseus_treebank(xml_path::String)
    content = read(xml_path, String)
    word_regex = r"<word\s+([^>]+?)\s*/>"
    words = Tuple{String,String,String}[]

    for m in eachmatch(word_regex, content)
        attrs_str = m[1]
        # Extract attributes (handles both " and ' quoting)
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
    println("=== Perseus Treebank → Dramaturg alignment ===")
    println("XML:  $XML_PATH")
    println("CEX:  $TOKENIZED_CEX")

    # 1. Load both sides
    cex_tokens = load_tokenized_cex(TOKENIZED_CEX)
    xml_words  = parse_perseus_treebank(XML_PATH)
    println("Loaded $(length(cex_tokens)) CEX tokens and $(length(xml_words)) XML words.")

    # 2. Normalise everything (round-trip)
    norm_xml = [normalize_form(form) for (form, _, _) in xml_words]
    norm_cex = [normalize_form(form) for (_, form) in cex_tokens]

    # 3. ALIGNMENT LOGIC (this is the block you can modify for other XML formats)
    matched = Tuple{String, String, String, String}[]   # (urn, surface_u, lemma_u, postag)
    beta_failures = String[]
    cex_i, xml_i = 1, 1

    while cex_i ≤ length(cex_tokens) && xml_i ≤ length(xml_words)
        n_cex = norm_cex[cex_i]
        n_xml = norm_xml[xml_i]

        # Catch BetaCode failures in XML
        if n_xml == "#FAILED#"
            println("got a #FAILED#")
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
            # Mismatch → skip the extra token that exists only in the XML edition
            # (quotation marks, editorial marks, etc.)
            xml_i += 1
        end
    end

    # Remaining CEX tokens have no match
    unmatched_cex = String[]
    while cex_i ≤ length(cex_tokens)
        urn, form = cex_tokens[cex_i]
        push!(unmatched_cex, "$urn\t$form")
        cex_i += 1
    end

    # 4. Write triplets.tsv (exactly the 5-column format expected by align_lemmata.jl)
    triplets = String[]
    for (_, surface_u, lemma_u, postag) in matched
        surface_beta = unicodeToBeta(surface_u)
        lemma_beta   = unicodeToBeta(lemma_u)
        push!(triplets, join([surface_u, surface_beta, lemma_u, lemma_beta, postag], '\t'))
    end
    write(OUTPUT_TRIPLETS, join(triplets, "\n") * "\n")
    write(MATCHED_URNS, join([u for (u,_,_,_) in matched], "\n") * "\n")

    # 5. Error report
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
    println("   Triplets → $OUTPUT_TRIPLETS  ($(length(triplets)) rows)")
    println("   Matched URNs → $MATCHED_URNS")
    println("   Error report → $ERROR_REPORT")
    println()
    println("Next steps:")
    println("1. Temporarily point config.toml [morphology] morph_pos_triplets at $OUTPUT_TRIPLETS")
    println("2. Run: julia scripts/align_lemmata.jl")
    println("3. Combine (one-liner in the REPL or a tiny script):")
    println("   urns = readlines(\"$MATCHED_URNS\")")
    println("   aligned = readlines(\"data/indexes/The_Homeric_Hymn_to_Demeter_triplets_lemmata.tsv\")  # whatever your config calls it")
    println("   open(\"source-data/edited_morphology/The_Homeric_Hymn_to_Demeter/editorial_picks.tsv\", \"w\") do io")
    println("       for (u, a) in zip(urns, aligned)")
    println("           println(io, u * \"\\t\" * a)")
    println("       end")
    println("   end")
    println("You now have a full editorial_picks.tsv ready for Dramaturg!")
end

main()