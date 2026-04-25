module Morphology

export parse_morpheus_to_triplets

# ==================== Mapping dictionaries (from your earlier work) ====================
const pos_type_map = Dict(
    "particle" => "g", "conj" => "c", "prep" => "r", "adverb" => "d",
    "interj" => "i", "pronoun" => "p", "pron1" => "p", "pron2" => "p",
    "pron" => "p", "relative" => "p", "indef" => "p", "article" => "l",
    "numeral" => "m", "punct" => "u"
)

const person_map   = Dict("1st" => "1", "2nd" => "2", "3rd" => "3")
const number_map   = Dict("sg" => "s", "pl" => "p", "dual" => "d")
const tense_map    = Dict("pres" => "p", "impf" => "i", "fut" => "f",
                          "aor" => "a", "perf" => "r", "plup" => "l", "futperf" => "t")
const mood_map     = Dict("ind" => "i", "subj" => "s", "opt" => "o",
                          "imperat" => "m", "inf" => "n", "part" => "p")
const voice_map    = Dict("act" => "a", "mid" => "m", "pass" => "p", "mp" => "e")
const gender_map   = Dict("masc" => "m", "fem" => "f", "neut" => "n")
const case_map     = Dict("nom" => "n", "gen" => "g", "dat" => "d",
                          "acc" => "a", "voc" => "v", "loc" => "l")
const degree_map   = Dict("compar" => "c", "superl" => "s")

const article_lemmas = Set(["o(", "h(", "to/"])

"""
    clean_lemma(lemma_str::String) -> String

Simple cleaning so that "ai)ti/a_n,ai)/tios" becomes the dictionary forms
you showed in your example (ai)ti/a and ai)/tios).
"""
function clean_lemma(lemma_str::String)::String
    lemma = strip(lemma_str)
    # Remove trailing _n / _ou style stem markers that Morpheus sometimes adds
    lemma = replace(lemma, r"_.+$" => "")
    return lemma
end

"""
    parse_morpheus_to_triplets(input_path::String, output_triplets::String, error_log::String="")

Reads the raw Morpheus batch file (analysis.txt) and writes a clean TSV of
surface-form → lemma → Perseus-style POS tag triplets exactly as you requested.

Example output line:
ai)ti/an	ai)/tios	n-s---fa-
"""
function parse_morpheus_to_triplets(input_path::String, output_triplets::String, error_log::String="")
    lines = readlines(input_path)
    open(output_triplets, "w") do out
        open(error_log, "w") do err
            i = 1
            while i ≤ length(lines)
                line = strip(lines[i])
                isempty(line) && (i += 1; continue)
                surface = line
                i += 1
                (i > length(lines)) && break

                parsing_line = lines[i]
                i += 1

                # Extract every <NL>…</NL> block (handles multiple analyses per surface)
                for m in eachmatch(r"<NL>(.*?)</NL>", parsing_line)
                    content = m.captures[1]
                    tokens = filter(!isempty, split(content, r"\s+"))

                    length(tokens) < 2 && (write(err, "Invalid line: $content\n"); continue)

                    morph_pos   = tokens[1]
                    lemma_key   = tokens[2]
                    attr        = tokens[3:end]

                    # === Lemma handling (comma-separated) ===
                    lemma_parts = split(lemma_key, ",")
                    lemmas = [clean_lemma(lp) for lp in lemma_parts if !isempty(strip(lp))]

                    # Default tag components (9-character Perseus style)
                    pos = ""
                    person = "-"; num = "-"; tense = "-"; mood = "-"; voice = "-"
                    gend = "-"; cas = "-"; degree = "-"

                    is_indecl = "indeclform" ∈ attr

                    features = copy(attr)
                    filter!(a -> a != "part", features)          # ignore participle marker

                    stem_class = ""
                    type_str   = ""
                    if is_indecl && !isempty(attr)
                        type_str = attr[end]
                        filter!(a -> a != "indeclform" && a != type_str, features)
                    elseif !isempty(attr)
                        stem_class = pop!(features)
                    end

                    # POS determination (keeps your earlier sophisticated logic)
                    if morph_pos == "V"
                        pos = "v"
                    elseif morph_pos == "P"
                        pos = "v"; mood = "p"
                    elseif morph_pos == "D"
                        pos = "d"
                    elseif morph_pos == "A"
                        pos = "a"
                    elseif morph_pos == "N"
                        if is_indecl && haskey(pos_type_map, type_str)
                            pos = pos_type_map[type_str]
                        elseif lemma_key ∈ article_lemmas || any(l -> l ∈ article_lemmas, lemmas)
                            pos = "l"
                        elseif "compar" ∈ attr || "superl" ∈ attr
                            pos = "a"
                        elseif any(f -> f ∈ keys(gender_map), features) ||
                               any(f -> f ∈ keys(case_map), features) ||
                               any(f -> f ∈ keys(number_map), features)
                            # adjective vs noun heuristic from your original script
                            if !is_indecl && stem_class != "" && count(==('_'), stem_class) == 2
                                pos = "a"
                            else
                                pos = "n"
                            end
                        else
                            pos = "x"  # fallback
                        end
                    else
                        write(err, "Unknown morph POS: $morph_pos for $content\n")
                        continue
                    end

                    # Map features
                    for a in features
                        occursin("/", a) && continue
                        if pos == "v" && haskey(person_map, a);      person = person_map[a]
                        elseif haskey(number_map, a);                num    = number_map[a]
                        elseif haskey(tense_map, a);                 tense  = tense_map[a]
                        elseif haskey(mood_map, a);                  mood   = mood_map[a]
                        elseif haskey(voice_map, a);                 voice  = voice_map[a]
                        elseif haskey(gender_map, a);                gend   = gender_map[a]
                        elseif haskey(case_map, a);                  cas    = case_map[a]
                        elseif haskey(degree_map, a);                degree = degree_map[a]
                        end
                    end

                    # Handle slash ambiguities (nom/voc, masc/fem, etc.)
                    gend_list = [gend]; cas_list = [cas]; num_list = [num]
                    for a in features
                        if occursin("/", a)
                            parts = split(a, "/")
                            if all(p -> haskey(gender_map, p), parts)
                                gend_list = [gender_map[p] for p in parts]
                            elseif all(p -> haskey(case_map, p), parts)
                                cas_list = [case_map[p] for p in parts]
                            elseif all(p -> haskey(number_map, p), parts)
                                num_list = [number_map[p] for p in parts]
                            end
                        end
                    end

                    isempty(pos) && (write(err, "Could not determine POS for $content\n"); continue)

                    # Generate one triplet per lemma × per ambiguity combination
                    for lemma in lemmas
                        for g in gend_list
                            for c in cas_list
                                for n in num_list
                                    tag = pos * person * n * tense * mood * voice * g * c * degree
                                    println(out, "$surface\t$lemma\t$tag")
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    println("✅ Triplets written to $output_triplets")
    if !isempty(error_log)
        println("   Errors (if any) logged to $error_log")
    end
end

end # module Morphology