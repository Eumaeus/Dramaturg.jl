# scripts/generate_html_reader_pages.jl
# Builds reader pages with drama-specific speaker + intra-line handling.

using TOML
using Markdown
using Dates

# ------------------------------------------------------------------
# Helpers
# ------------------------------------------------------------------
function get_citation_unit(urn::String, level::Int, text_urn::String)::String
    if !startswith(urn, text_urn)
        return "??"
    end
    passage = split(urn, ':')[end]
    parts = split(passage, '.')
    n = min(level, length(parts))
    return join(parts[1:n], '.')
end

function get_sub_citation(urn::String, level::Int, text_urn::String)::String
    if !startswith(urn, text_urn)
        return "??"
    end
    passage = split(urn, ':')[end]
    if occursin(".speaker", passage)
        base = split(passage, ".speaker")[1]
    elseif occursin(".text", passage)
        base = split(passage, ".text")[1]
    else
        base = passage
    end
    parts = split(base, '.')
    n = min(level + 1, length(parts))
    return join(parts[1:n], '.')
end

# ------------------------------------------------------------------
# Render Greek text body
# ------------------------------------------------------------------
function render_greek_text(tokens::Vector{Tuple{String,String}}, genre::String, citation_level::Int, text_urn::String)::String
    if genre != "drama"
        # Original logic for prose / poetry
        parts = String[]
        current_speaker = ""
        current_citation = ""
        current_unit_spans = String[]
        for (urn, tok) in tokens
            passage = split(urn, ':')[end]
            if occursin(".speaker", passage)
                speaker = tok
                if speaker != current_speaker && !isempty(speaker)
                    push!(parts, """<div class="speaker-attribution"><strong>$speaker</strong></div>""")
                    current_speaker = speaker
                end
                continue
            end
            this_cit = get_citation_unit(urn, citation_level, text_urn)
            if this_cit != current_citation
                if !isempty(current_unit_spans)
                    joined = join(current_unit_spans, " ")
                    push!(parts, joined)
                    push!(parts, "</div>")
                end
                current_citation = this_cit
                current_unit_spans = String[]
                push!(parts, """<div class="citation-unit" data-citation="$this_cit">""")
                push!(parts, """<span class="citation-label">$this_cit</span>""")
            end
            push!(current_unit_spans, """<span class="text_token" data-ctsurn="$urn">$tok</span>""")
        end
        if !isempty(current_unit_spans)
            joined = join(current_unit_spans, " ")
            push!(parts, joined)
            push!(parts, "</div>")
        end
        return join(parts, "\n")
    else
        # === DRAMA LOGIC (new) ===
        parts = String[]
        current_main = ""
        current_sub = ""
        current_speaker = ""
        citation_label_placed = false
        inside_inline = false

        for (urn, tok) in tokens
            passage = split(urn, ':')[end]
            this_main = get_citation_unit(urn, citation_level, text_urn)
            this_sub  = get_sub_citation(urn, citation_level, text_urn)

            # Close previous main unit
            if this_main != current_main && !isempty(current_main)
                if inside_inline
                    push!(parts, "</div>")  # inline-speech
                    inside_inline = false
                end
                push!(parts, "</div>")  # citation-unit
            end

            # Start new main citation unit
            if this_main != current_main
                current_main = this_main
                push!(parts, """<div class="citation-unit" data-citation="$this_main">""")
                citation_label_placed = false
                current_sub = ""
                current_speaker = ""
                inside_inline = false
            end

            # Start new inline-speech on sub-citation change (or first speech)
            if this_sub != current_sub
                if inside_inline
                    push!(parts, "</div>")
                end
                push!(parts, """<div class="inline-speech">""")
                inside_inline = true
                current_sub = this_sub

                # Speaker token → render attribution + citation label (after speaker)
                if occursin(".speaker", passage)
                    speaker = tok
                    if !isempty(speaker)
                        push!(parts, """<div class="speaker-attribution"><strong>$speaker</strong></div>""")
                        current_speaker = speaker
                    end
                    if !citation_label_placed
                        push!(parts, """<span class="citation-label">$this_main</span>""")
                        citation_label_placed = true
                    end
                    continue  # speaker never becomes a text_token
                else
                    # Text token starting a new sub-speech (continuation line, no repeated speaker)
                    if !citation_label_placed
                        push!(parts, """<span class="citation-label">$this_main</span>""")
                        citation_label_placed = true
                    end
                end
            end

            # Render normal text token
            if !occursin(".speaker", passage)
                push!(parts, """<span class="text_token" data-ctsurn="$urn">$tok</span>""")
            end
        end

        # Close final containers
        if inside_inline
            push!(parts, "</div>")
        end
        if !isempty(current_main)
            push!(parts, "</div>")
        end
        return join(parts, "\n")
    end
end


# ------------------------------------------------------------------
# NEW: Load editorial morphology choices from a directory of .tsv files
# ------------------------------------------------------------------
function load_editorial_index(editor_dir::String,
                              token_dict::Dict{String,String},
                              morph_dict::Dict{String,NamedTuple{(:desc,:lsj),Tuple{String,String}}})::Tuple{Dict{String,String},String}
    editorial = Dict{String,String}()
    conflict_lines = String[]

    if !isdir(editor_dir)
        return editorial, ""
    end

    tsv_files = filter(f -> endswith(lowercase(f), ".tsv"), readdir(editor_dir))
    if isempty(tsv_files)
        return editorial, ""
    end

    # mappings[cts_urn] = list of (morph_urn, tsv_filename, mod_date_str)
    mappings = Dict{String,Vector{Tuple{String,String,String}}}()

    for tsv in tsv_files
        fullpath = joinpath(editor_dir, tsv)
        isfile(fullpath) || continue

        mtime = stat(fullpath).mtime
        date_str = Dates.format(Dates.unix2datetime(mtime), "yyyy-mm-dd HH:MM:SS")

        for line in readlines(fullpath)
            line = strip(line)
            isempty(line) && continue
            parts = split(line, '\t')
            length(parts) < 2 && continue
            cts = strip(parts[1])
            morph = strip(parts[2])

            if !haskey(mappings, cts)
                mappings[cts] = Tuple{String,String,String}[]
            end
            push!(mappings[cts], (morph, tsv, date_str))
        end
    end

    for (cts, entries) in mappings
        # Group by morph_urn (duplicates across files are allowed)
        morph_to_sources = Dict{String,Vector{Tuple{String,String}}}()
        for (morph, tsvf, dt) in entries
            if !haskey(morph_to_sources, morph)
                morph_to_sources[morph] = Tuple{String,String}[]
            end
            push!(morph_to_sources[morph], (tsvf, dt))
        end

        if length(morph_to_sources) > 1
            # CONFLICT
            token_text = get(token_dict, cts, "[TOKEN TEXT NOT FOUND]")
            push!(conflict_lines, "CONFLICT for CTS-URN: $cts")
            push!(conflict_lines, "Token: \"$token_text\"")
            for (morph, sources) in morph_to_sources
                for (tsvf, dt) in sources
                    desc = haskey(morph_dict, morph) ? morph_dict[morph].desc : "[NO DESCRIPTION FOUND]"
                    push!(conflict_lines, "  • $morph  ←  $tsvf  ($dt)")
                    push!(conflict_lines, "    desc: $desc")
                end
            end
            push!(conflict_lines, "────────────────────────────────────────")
        else
            # OK – take the single morphology choice
            the_morph = first(keys(morph_to_sources))
            editorial[cts] = the_morph
        end
    end

    if isempty(conflict_lines)
        return editorial, ""
    else
        report = """
        EDITORIAL INDEX CONFLICTS
        =========================
        Generated: $(Dates.now())
        Directory scanned: $editor_dir

        $(join(conflict_lines, "\n"))

        Build continuing WITHOUT editorial choices for the conflicting CTS-URNs above.
        (They will fall back to the default morphology index.)
        """
        return editorial, report
    end
end



# ------------------------------------------------------------------
# NEW: Data loaders for morphology + lexicon
# ------------------------------------------------------------------
function load_morph_index(path::String)::Dict{String,Vector{String}}
    idx = Dict{String,Vector{String}}()
    for line in readlines(path)
        line = strip(line)
        isempty(line) && continue
        parts = split(line, '\t')
        length(parts) < 2 && continue
        token_urn = strip(parts[1])
        morph_urn = strip(parts[2])
        if !haskey(idx, token_urn)
            idx[token_urn] = String[]
        end
        push!(idx[token_urn], morph_urn)
    end
    idx
end

function load_morph_dict(path::String)::Dict{String,NamedTuple{(:desc,:lsj),Tuple{String,String}}}
    d = Dict{String,NamedTuple{(:desc,:lsj),Tuple{String,String}}}()
    for line in readlines(path)
        line = strip(line)
        startswith(line, "urn:cite2:fufolio:greekmorph") || continue
        fields = split(line, '#')
        length(fields) < 7 && continue
        morph_urn = strip(fields[1])
        desc = strip(fields[2])                     # the Markdown description you want
        # LSJ URN is reliably the 7th field (or the first field that looks like an LSJ URN)
        lsj = ""
        for f in fields
            if startswith(strip(f), "urn:cite2:hmt:lsj.chicago_md:")
                lsj = strip(f)
                break
            end
        end
        isempty(lsj) && length(fields) >= 7 && (lsj = strip(fields[7]))
        d[morph_urn] = (desc = desc, lsj = lsj)
    end
    d
end

function load_lsj_short_defs(path::String)::Dict{String,String}
    defs = Dict{String,String}()
    for line in readlines(path)
        line = strip(line)
        isempty(line) && continue
        parts = split(line, '\t', limit = 2)
        length(parts) == 2 || continue
        urn = strip(parts[1])
        def = strip(parts[2])
        defs[urn] = def
    end
    defs
end

# ------------------------------------------------------------------
# UPDATED: Build morphology HTML block with editorial top-choice support
# ------------------------------------------------------------------
function build_morphdata_html(tokens::Vector{Tuple{String,String}},
                              morph_index::Dict{String,Vector{String}},
                              morph_dict::Dict{String,NamedTuple{(:desc,:lsj),Tuple{String,String}}},
                              lsj_defs::Dict{String,String},
                              lsj_url::String,
                              editorial_choices::Dict{String,String})::String   # NEW param
    parts = String[]
    processed = Set{String}()

    for (urn, _) in tokens
        occursin(".speaker", urn) && continue
        urn in processed && continue
        push!(processed, urn)

        haskey(morph_index, urn) || continue
        possible_urns = morph_index[urn]

        chosen = get(editorial_choices, urn, nothing)

        push!(parts, """<div class="morph4token" data-tokenurn="$urn">""")

        if chosen !== nothing && chosen ∈ possible_urns
            # === EDITOR’S PREFERRED PARSING (top choice) ===
            push!(parts, """<div class="editor-preferred-header sansfont"><strong>📌 Editor’s Preferred Parsing</strong></div>""")

            # Render the chosen entry
            if haskey(morph_dict, chosen)
                entry = morph_dict[chosen]
                desc_html = Markdown.html(Markdown.parse(entry.desc))
                lsj_urn = entry.lsj
                shortdef = get(lsj_defs, lsj_urn, "[No short definition available]")

                push!(parts, """
                    <div class="parse_and_lex editor-preferred" data-morphurn="$chosen">
                        <div class="formparsing" data-morphurn="$chosen">
                            $desc_html
                        </div>
                        <div class="lsj_shortdef" data-lsjurn="$lsj_urn">
                            <a href="$(lsj_url * "?urn=" * lsj_urn)" class="shortdeflink">$shortdef</a>
                        </div>
                    </div>
                """)
            end

            # Remaining possibilities
            others = filter(m -> m != chosen, possible_urns)
            if !isempty(others)
                push!(parts, """<div class="possible-parsings-header sansfont"><strong>Possible Parsings of this Form</strong></div>""")
                for murn in others
                    haskey(morph_dict, murn) || continue
                    entry = morph_dict[murn]
                    desc_html = Markdown.html(Markdown.parse(entry.desc))
                    lsj_urn = entry.lsj
                    shortdef = get(lsj_defs, lsj_urn, "[No short definition available]")

                    push!(parts, """
                        <div class="parse_and_lex" data-morphurn="$murn">
                            <div class="formparsing" data-morphurn="$murn">
                                $desc_html
                            </div>
                            <div class="lsj_shortdef" data-lsjurn="$lsj_urn">
                                <a href="$(lsj_url * "?urn=" * lsj_urn)" class="shortdeflink">$shortdef</a>
                            </div>
                        </div>
                    """)
                end
            end
        else
            # No editorial choice – render all possibilities exactly as before
            for murn in possible_urns
                haskey(morph_dict, murn) || continue
                entry = morph_dict[murn]
                desc_html = Markdown.html(Markdown.parse(entry.desc))
                lsj_urn = entry.lsj
                shortdef = get(lsj_defs, lsj_urn, "[No short definition available]")

                push!(parts, """
                    <div class="parse_and_lex" data-morphurn="$murn">
                        <div class="formparsing" data-morphurn="$murn">
                            $desc_html
                        </div>
                        <div class="lsj_shortdef" data-lsjurn="$lsj_urn">
                            <a href="$(lsj_url * "?urn=" * lsj_urn)" class="shortdeflink">$shortdef</a>
                        </div>
                    </div>
                """)
            end
        end

        push!(parts, "</div>")   # close morph4token
    end
    join(parts, "\n")
end


# ------------------------------------------------------------------
# Main (updated with editorial loading + token collection for conflicts)
# ------------------------------------------------------------------
function main()
    config_path = joinpath(@__DIR__, "config.toml")
    config = TOML.parsefile(config_path)

    input = config["input"]
    output = config["output"]
    editorial = get(config, "editorial", Dict{String,Any}())

    file_name = input["file_name"]
    text_title_md = input["text_title"]
    text_urn = input["text_urn"]
    genre = lowercase(input["text_genre"])
    citation_level = input["citation_level"]

    html_temp_dir = output["html_temp_dir"]
    pages_dir = output["html_output_dir"]
    text_site_dir = dirname(pages_dir)

    mkpath(pages_dir)

    template_path = joinpath(output["html_template_dir"], output["html_page_template"])
    template = read(template_path, String)

    txt_files = sort(filter(f -> endswith(lowercase(f), ".txt"), readdir(html_temp_dir)))
    if isempty(txt_files)
        error("No chunk .txt files found in $html_temp_dir")
    end

    # === NEW: Collect ALL tokens once (needed for conflict reporting) ===
    full_token_dict = Dict{String,String}()
    for txt_file in txt_files
        chunk_path = joinpath(html_temp_dir, txt_file)
        for line in readlines(chunk_path)
            if occursin('\t', line)
                urn, text = split(line, '\t', limit=2)
                full_token_dict[urn] = text
            end
        end
    end
    println("Collected $(length(full_token_dict)) tokens for editorial processing.")

    # === Load morphology + lexicon data (unchanged) ===
    morph_index = load_morph_index(config["morphology"]["morph_token_index"])
    morph_dict  = load_morph_dict(config["editorial"]["master_morph_dict"])
    lsj_defs    = load_lsj_short_defs(config["lexicon"]["lsj_short"])
    lsj_url     = output["lsj_url"]

    # === NEW: Load editorial choices with conflict detection ===
    editorial_dir = get(editorial, "editor_index_files", "")
    error_path    = get(editorial, "editor_index_error", "")
    editorial_choices, conflict_report = load_editorial_index(editorial_dir, full_token_dict, morph_dict)

    if !isempty(conflict_report) && !isempty(error_path)
        mkpath(dirname(error_path))
        write(error_path, conflict_report)
        println("⚠️  Editorial conflicts written to: $error_path")
    elseif !isempty(editorial_choices)
        println("✅ Loaded $(length(editorial_choices)) editorial morphology choices (no conflicts).")
    else
        println("ℹ️  No editorial .tsv files found (or directory empty).")
    end

    println("Generating $(length(txt_files)) reader pages (drama mode: $(genre == "drama"))...")

    for (idx, txt_file) in enumerate(txt_files)
        chunk_base = replace(txt_file, r"\.txt$"i => "")
        chunk_path = joinpath(html_temp_dir, txt_file)
        page_path = joinpath(pages_dir, chunk_base * ".html")

        lines = readlines(chunk_path)
        tokens = Tuple{String,String}[]
        for line in lines
            if occursin('\t', line)
                urn, text = split(line, '\t', limit=2)
                push!(tokens, (urn, text))
            end
        end

        greek_html = render_greek_text(tokens, genre, citation_level, text_urn)

        # === UPDATED: Pass editorial_choices to the builder ===
        morphdata_html = build_morphdata_html(tokens, morph_index, morph_dict, lsj_defs, lsj_url, editorial_choices)

        # Passage span, navigation, title, etc. (unchanged)
        text_cits = [get_citation_unit(urn, citation_level, text_urn) for (urn, tok) in tokens if !occursin(".speaker", urn)]
        passage_span = if length(text_cits) >= 1
            first_c = text_cits[1]
            last_c  = text_cits[end]
            first_c == last_c ? first_c : first_c * "–" * last_c
        else
            ""
        end

        prev_href = idx > 1 ? replace(txt_files[idx-1], r"\.txt$"i => "") * ".html" : "#"
        next_href = idx < length(txt_files) ? replace(txt_files[idx+1], r"\.txt$"i => "") * ".html" : "#"
        navigation = """
        <a href="$prev_href">← Previous</a>
        <a href="../index.html" id="contents_link">Contents</a> | 
        <a href="../../index.html" id="home_link">Editions Home</a>
        <a href="$next_href" style="float:right;">Next →</a>
        """

        title_and_span_html = Markdown.html(Markdown.parse(text_title_md * " " * passage_span))
        title_html = Markdown.html(Markdown.parse(text_title_md))
        page_title = replace(title_html, r"<[^>]+>" => "")

        # Fill template
        filled = template
        filled = replace(filled, "{{page_title}}" => page_title)
        filled = replace(filled, "{{title}}" => title_and_span_html)
        filled = replace(filled, "{{passage_span}}" => passage_span)
        filled = replace(filled, "{{navigation}}" => navigation)
        filled = replace(filled, "{{greek_text}}" => greek_html)
        filled = replace(filled, "{{morph_data}}" => morphdata_html)

        write(page_path, filled)
        
        println("   ✓ $chunk_base.html  ($passage_span)")
    end

    # CSS update (unchanged)
    # ... (identical)

    println("\n✅ Reader pages regenerated with editorial index support!")
    println("Open the HTML edition – top choices are now clearly marked.")
end

main()