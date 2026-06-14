# scripts/generate_html_index.jl
# Now copies production CSS/JS from editions/templates/ (instead of placeholders)

using TOML
using Markdown
using Dramaturg

# NEW helpers for nice TOC labels
function format_passage_range(first_cit::String, last_cit::String, level::Int)::String


    if level == 1
        fparts = split(first_cit, '.')
        lparts = split(last_cit, '.')

        #return "Passages $(first_cit)–$(last_cit)"
        return "Passages $(fparts[1])–$(lparts[1])"
    else
        fparts = split(first_cit, '.')
        return "Passages $(first_cit) – $(last_cit)"
        #=
        if length(fparts) >= 2 && length(lparts) >= 2 && fparts[1] == lparts[1]
            return "Passages $(fparts[1]).$(fparts[2])–$(fparts[1]).$(lparts[2])"
        else
            return "Passages $(first_cit)–$(last_cit)"
        end
        =#
    end
end

function generate_toc_html(html_temp_dir::String, citation_level::Int)::String
    txt_files = sort(filter(f -> endswith(lowercase(f), ".txt"), readdir(html_temp_dir)))
    chunks = []
    for txt_file in txt_files
        chunk_base = replace(txt_file, r"\.txt$"i => "")
        page_href = "pages/" * chunk_base * ".html"

        lines = readlines(joinpath(html_temp_dir, txt_file))
        isempty(lines) && continue
        first_urn = split(lines[1], '\t')[1]
        last_urn  = split(lines[end], '\t')[1]

        first_cit = Dramaturg.get_natural_unit(String(first_urn))
        last_cit  = Dramaturg.get_natural_unit(String(last_urn))
        range_label = format_passage_range(first_cit, last_cit, citation_level)

        push!(chunks, (href = page_href, range_label = range_label,
                       first_cit = first_cit, last_cit = last_cit))
    end

    isempty(chunks) && return "<p>No chunks found.</p>"

    if length(chunks) <= 8
        items = ["<li><a href=\"$(c.href)\">$(c.range_label)</a></li>" for c in chunks]
        return "<ul>\n" * join(items, "\n") * "\n</ul>"
    end

    # === 1-level citation scheme (e.g. Frogs, Hymn to Demeter) ===
    if citation_level == 1
        group_size = 8
        toc = ""
        for i in range(1, length(chunks), step = group_size)
            group = chunks[i:min(i+group_size-1, length(chunks))]
            g_first = group[1].first_cit
            g_last  = group[end].last_cit

            g_first_parts = split(g_first, '.')
            g_last_parts = split(g_last, '.')

            group_range = "Passages $(g_first_parts[1])–$(g_last_parts[1])"
            ul_items = ["<li><a href=\"$(c.href)\">$(c.range_label)</a></li>" for c in group]
            toc *= """
            <details>
              <summary>$group_range</summary>
              <ul>
                $(join(ul_items, "\n"))
              </ul>
            </details>
            """
        end
        return toc
    end

    # === 2-level citation scheme (e.g. Herodotus, Iliad) ===
    # === NOTE!! This fails below, sorted_books, with non-numeric citation-values
    book_groups = Dict{String, Vector}()
    for c in chunks
        top = split(c.first_cit, '.')[1]
        if !haskey(book_groups, top)
            book_groups[top] = []
        end
        push!(book_groups[top], c)
    end

    # Trying this instead! Allows for non-numeric citation-values
    test_books = Vector{String}()
    for c in chunks
        top = split(c.first_cit, '.')[1] |> String
        if !( top in test_books )
            push!(test_books, top)
        end
    end 

    # sorted_books = sort(collect(keys(book_groups)), by = x -> parse(Int, x))
    sorted_books = test_books
    num_books = length(sorted_books)

    toc = ""
    book_group_size = 8

    for i in range(1, num_books, step = book_group_size)
        book_subgroup = sorted_books[i:min(i+book_group_size-1, num_books)]
        if length(book_subgroup) > 1
            super_label = "$(book_subgroup[1]) – $(book_subgroup[end])"
            super_content = ""
            for b in book_subgroup
                b_chunks = book_groups[b]
                b_label = "Chapter “$(b)”"
                sub_list = length(b_chunks) <= 8 ?
                    "<ul>" * join(["<li><a href=\"$(c.href)\">$(c.range_label)</a></li>" for c in b_chunks], "\n") * "</ul>" :
                    generate_chunk_groups(b_chunks)
                super_content *= """
                <details>
                  <summary>$b_label</summary>
                  $sub_list
                </details>
                """
            end
            toc *= """
            <details>
              <summary>$super_label</summary>
              $super_content
            </details>
            """
        else
            b = book_subgroup[1]
            b_chunks = book_groups[b]
            b_label = "Book $b"
            sub_list = length(b_chunks) <= 8 ?
                "<ul>" * join(["<li><a href=\"$(c.href)\">$(c.range_label)</a></li>" for c in b_chunks], "\n") * "</ul>" :
                generate_chunk_groups(b_chunks)
            toc *= """
            <details>
              <summary>$b_label</summary>
              $sub_list
            </details>
            """
        end
    end
    return toc
end

# Tiny helper for long books (used in 2-level TOC)
function generate_chunk_groups(chunks_list)
    group_size = 8
    s = ""
    for i in range(1, length(chunks_list), step = group_size)
        g = chunks_list[i:min(i+group_size-1, length(chunks_list))]
        g_first = g[1].first_cit
        g_last  = g[end].last_cit
        g_range = "Passages $(g_first)–$(g_last)"
        ul = join(["<li><a href=\"$(c.href)\">$(c.range_label)</a></li>" for c in g], "\n")
        s *= """
        <details>
          <summary>$g_range</summary>
          <ul>$ul</ul>
        </details>
        """
    end
    return s
end

function main()
    config_path = joinpath(@__DIR__, "config.toml")
    config = TOML.parsefile(config_path)

    Dramaturg.chunk_for_html_edition(config)  # now uses citation_level

    input = config["input"]
    output = config["output"]

    file_name = input["file_name"]
    text_title_md = input["text_title"]
    citation_level = get(input, "citation_level", 1)

    html_temp_dir = output["html_temp_dir"]
    pages_dir = output["html_output_dir"]
    editions_dir = output["editions_dir"]
    text_site_dir = dirname(pages_dir)
    index_path = joinpath(text_site_dir, "index.html")

    # Ensure directories
    mkpath(text_site_dir)
    mkpath(pages_dir)
    mkpath(joinpath(text_site_dir, "css"))
    mkpath(joinpath(text_site_dir, "js"))

    # Top-level directories
    mkpath(editions_dir)
    mkpath(joinpath(editions_dir, "css"))
    mkpath(joinpath(editions_dir, "js"))

    # === COPY TEMPLATED ASSETS ===
    template_dir = output["html_template_dir"]
    cp(joinpath(template_dir, "css", "style.css"),
       joinpath(text_site_dir, "css", "style.css"),
       force = true)
    cp(joinpath(template_dir, "css", "logo.png"),
       joinpath(text_site_dir, "css", "logo.png"),
       force = true)
    cp(joinpath(template_dir, "js", "interactive.js"),
       joinpath(text_site_dir, "js", "interactive.js"),
       force = true)
    cp(joinpath(template_dir, "css", "style.css"),
       joinpath(editions_dir, "css", "style.css"),
       force = true)
    cp(joinpath(template_dir, "css", "logo.png"),
       joinpath(editions_dir, "css", "logo.png"),
       force = true)

    cp(joinpath(template_dir, "js", "interactive.js"),
       joinpath(editions_dir, "js", "interactive.js"),
       force = true)
    cp(joinpath(template_dir, "homepage", "index.html"),
       joinpath(editions_dir, "index.html"),
       force = true)

    # Load templates
    template_dir = output["html_template_dir"]
    index_template_path = joinpath(template_dir, output["html_index_template"])
    index_template = read(index_template_path, String)

    # Build TOC with new human-readable labels + accordions
    toc_html = generate_toc_html(html_temp_dir, citation_level)

    # Title
    title_html = Markdown.html(Markdown.parse(text_title_md))
    page_title = replace(title_html, r"<[^>]+>" => "")

    frontmatter_md_path = output["md_frontmatter"]
    frontmatter_html = isfile(frontmatter_md_path) ?
        Markdown.html(Markdown.parse(read(frontmatter_md_path, String))) :
        "<p><em>Frontmatter will appear here.</em></p>"

    bibliography_md_path = output["md_bibliography"]
    bibliography_html = isfile(bibliography_md_path) ?
        Markdown.html(Markdown.parse(read(bibliography_md_path, String))) :
        "<p><em>Bibliography will appear here.</em></p>"

    txt_files = sort(filter(f -> endswith(lowercase(f), ".txt"), readdir(html_temp_dir)))
    if isempty(txt_files)
        error("No chunked .txt files found in $(html_temp_dir)")
    end
    first_chunk_base = replace(first(txt_files), r"\.txt$"i => "")
    first_page_href = "pages/" * first_chunk_base * ".html"

    navigation_html = """
    <a href="../index.html">Editions Home</a>
    <a href="$(first_page_href)" style="float: right; font-weight: bold;">Start Reading</a>
    """

    # Fill template
    filled = index_template
    filled = replace(filled, "{{title}}" => title_html)
    filled = replace(filled, "{{page_title}}" => page_title)
    filled = replace(filled, "{{navigation}}" => navigation_html)
    filled = replace(filled, "{{frontmatter}}" => frontmatter_html)
    filled = replace(filled, "{{bibliography}}" => bibliography_html)
    filled = replace(filled, "{{generated_toc}}" => toc_html)

    # Fix paths for index.html (root level)
    filled = replace(filled, "../css/style.css" => "css/style.css")
    filled = replace(filled, "../js/interactive.js" => "js/interactive.js")

    write(index_path, filled)

    println("Index + assets copied from templates")
    println("   • CSS → $(text_site_dir)/css/style.css")
    println("   • JS  → $(text_site_dir)/js/interactive.js")
    println("   • Index page: $(index_path)")
    println("Ready for reader pages!")
end

main()