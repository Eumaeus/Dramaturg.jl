#!/usr/bin/env julia
# utilities/import_perseus_treebank_morph.jl
# Perseus Treebank → Dramaturg alignment (bidirectional skips + debug)

using Dramaturg
using BetaReader
using Dates
using Unicode

# ── CONFIG ──
const XML_PATH          = "data/working_files/tlg0013.tlg002.perseus-grc1.tb.xml"
const TOKENIZED_CEX     = "data/tokenized/The_Homeric_Hymn_to_Demeter_tokenized.cex"
const OUTPUT_TRIPLETS   = "data/indexes/The_Homeric_Hymn_to_Demeter_perseus_triplets.tsv"
const MATCHED_URNS      = "data/indexes/The_Homeric_Hymn_to_Demeter_matched_urns.tsv"
const ERROR_REPORT      = "data/indexes/The_Homeric_Hymn_to_Demeter_perseus_alignment_errors.txt"
# ─────────────

"""
    form_to_beta(s::String) -> String
"""
function form_to_beta(s::String)::String
    isempty(s) && return ""
    # Elision markers (your original fixes)
    s = replace(s, '\u0343' => "'")
    s = replace(s, '\u2019' => "'")
    s = replace(s, '\u2018' => "'")

    # Idiosyncratic Perseus rho-elision (Δήμητῤ, etc.)
    # We don't want to replace rho+rough breathing.
    s = replace(s, r"ρ’" => "ρ'")
    s = replace(s, r"ζ̓" => "ζ'")
    s = replace(s, r"σ̓" => "σ'")
    s = replace(s, r"δ̓" => "δ'")


    # Canonical normalisation
    s = Unicode.normalize(s, :NFC)

    beta = unicodeToBeta(s)
    occursin('#', beta) && return "#FAILED#"
    return beta
end

function load_tokenized_cex(path::String)
    tokens = Tuple{String,String}[]
    for line in eachline(path)
        line = strip(line)
        isempty(line) && continue
        if startswith(line, "urn:cts:greekLit:tlg0013.tlg002.fucex:") &&
           occursin('#', line) &&
           occursin(".token.", line)
            parts = split(line, '#'; limit=2)
            length(parts) == 2 && push!(tokens, (parts[1], parts[2]))
        end
    end
    tokens
end

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
    println("=== Perseus Treebank → Dramaturg alignment (bidirectional) ===")
    println("XML:  $XML_PATH")
    println("CEX:  $TOKENIZED_CEX\n")

    cex_tokens = load_tokenized_cex(TOKENIZED_CEX)
    xml_words  = parse_perseus_treebank(XML_PATH)
    println("Loaded $(length(cex_tokens)) CEX tokens and $(length(xml_words)) XML words.\n")

    cex_beta = [form_to_beta(form) for (_, form) in cex_tokens]
    xml_beta = [form_to_beta(form) for (form, _, _) in xml_words]

    # ── DEBUG: first 15 BetaCode forms (before alignment) ──
    println("DEBUG: First 15 BetaCode forms (CEX vs XML)")
    for i in 1:min(15, length(cex_beta), length(xml_beta))
        cform = cex_tokens[i][2]
        xform = xml_words[i][1]
        println("  $i | CEX: '$(cform)' → β '$(cex_beta[i])'")
        println("      | XML: '$(xform)' → β '$(xml_beta[i])'")
    end
    println("\n")
    # ───────────────────────────────────────────────────────

    # ───────────────────────────────────────────────────────
    # IMPROVED ALIGNMENT LOGIC (this is the block you asked about)
    # Now allows skipping extras on EITHER the CEX side OR the XML side.
    matched = Tuple{String, String, String, String}[]   # (urn, surface_u, lemma_u, postag)
    beta_failures = String[]
    skips_cex = 0
    skips_xml = 0
    cex_i, xml_i = 1, 1

    while cex_i ≤ length(cex_tokens) && xml_i ≤ length(xml_words)
        b_cex = cex_beta[cex_i]
        b_xml = xml_beta[xml_i]

        if b_xml == "#FAILED#"
            xml_form = xml_words[xml_i][1]
            push!(beta_failures, "XML form failed BetaCode: $(xml_form)")
            xml_i += 1
            skips_xml += 1
            continue
        end

        if b_cex == b_xml
            # MATCH!
            urn, surface_u = cex_tokens[cex_i]
            _, lemma_u, postag = xml_words[xml_i]
            push!(matched, (urn, surface_u, lemma_u, postag))
            cex_i += 1
            xml_i += 1
        else
            # MISMATCH → lookahead of 1 on each side
            skipped = false

            # Case 1: CEX has an extra token (next CEX matches current XML)
            if cex_i < length(cex_beta) && cex_beta[cex_i + 1] == b_xml
                cex_i += 1
                skips_cex += 1
                skipped = true
            # Case 2: XML has an extra token (next XML matches current CEX)
            elseif xml_i < length(xml_beta) && xml_beta[xml_i + 1] == b_cex
                xml_i += 1
                skips_xml += 1
                skipped = true
            end

            if !skipped
                # fallback: skip XML (rare once normalization is good)
                xml_i += 1
                skips_xml += 1
            end
        end
    end
    # ───────────────────────────────────────────────────────

    # remaining unmatched CEX tokens
    unmatched_cex = String[]
    while cex_i ≤ length(cex_tokens)
        urn, form = cex_tokens[cex_i]
        push!(unmatched_cex, "$urn\t$form")
        cex_i += 1
    end

    # Write output files
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
        println(io, "Skipped CEX tokens: $skips_cex")
        println(io, "Skipped XML tokens: $skips_xml")
        println(io, "Unmatched CEX tokens: $(length(unmatched_cex))")
        println(io, "BetaCode failures:    $(length(beta_failures))\n")

        println(io, "=== DEBUG: First 15 BetaCode forms (CEX vs XML) ===")
        for i in 1:min(15, length(cex_beta), length(xml_beta))
            cform = cex_tokens[i][2]
            xform = xml_words[i][1]
            println(io, "$i | CEX: '$(cform)' → β '$(cex_beta[i])'")
            println(io, "   | XML: '$(xform)' → β '$(xml_beta[i])'")
        end

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
    println("   Matches: $(length(matched))")
    println("   Skipped CEX: $skips_cex | Skipped XML: $skips_xml")
    println("   Triplets      → $OUTPUT_TRIPLETS")
    println("   Matched URNs  → $MATCHED_URNS")
    println("   Error report  → $ERROR_REPORT")
    if length(matched) > 6
        println("\n🎉 Success! You can now run:")
        println("   julia scripts/align_lemmata.jl")
        println("   then combine the matched URNs with the lemmata output into editorial_picks.tsv")
    else
        println("\nStill only a few matches? Check the error report for the skip counts.")
    end
end

main()