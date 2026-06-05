# scripts/generate_html_index.jl
# Updated per your instructions:
#   • text_title (from config) is now treated as Markdown → HTML
#   • md_bibliography (new) is loaded + converted to HTML
#   • md_frontmatter (already present) continues to populate <div id="text">
#   • Removed passage_span entirely (your template no longer needs it)
#   • All Markdown processing happens at build time in Julia (no JS required)

using TOML
using Markdown
using Dramaturg

# Compatible regex escape for all Julia 1.x versions
function regex_escape(s::AbstractString)::String
    replace(s, r"([\\^\$.|?*+()[\]{}])" => s"\\\1")
end

# Helper to extract the citation-range part from a chunk filename
function get_citation(chunk_base::String, file_name::String)::String
    pattern = Regex("^" * regex_escape(file_name) * "_?")
    replace(chunk_base, pattern => "")
end

# Cleanly separated TOC generator
function generate_toc_html(html_temp_dir::String, file_name::String)::String
    txt_files = filter(f -> endswith(lowercase(f), ".txt"), readdir(html_temp_dir))
    sort!(txt_files)
    items = String[]
    for txt_file in txt_files
        chunk_base = replace(txt_file, r"\.txt$"i => "")
        citation = get_citation(chunk_base, file_name)
        page_href = "pages/" * chunk_base * ".html"
        push!(items, """<li><a href="$(page_href)">$(citation)</a></li>""")
    end
    return "<ul>\n" * join(items, "\n") * "\n</ul>"
end

# Main script
function main()
    config_path = joinpath(@__DIR__, "config.toml")
    config = TOML.parsefile(config_path)

    Dramaturg.chunk_for_html_edition(config)

    input = config["input"]
    output = config["output"]

    file_name = input["file_name"]
    text_title_md = input["text_title"]          # now Markdown

    html_temp_dir = output["html_temp_dir"]
    pages_dir = output["html_output_dir"]
    text_site_dir = dirname(pages_dir)
    index_path = joinpath(text_site_dir, "index.html")

    # Ensure directories exist
    mkpath(text_site_dir)
    mkpath(pages_dir)
    mkpath(joinpath(text_site_dir, "css"))
    mkpath(joinpath(text_site_dir, "js"))

    # Basic CSS (unchanged — clean + Aldine-inspired)
    css_content = """
    :root {
        --text-color: #222;
        --accent-color: #8b0000;
    }
    body {
        font-family: "Iowan Old Style", "Garamond", "EB Garamond", Georgia, serif;
        max-width: 42em;
        margin: 3rem auto;
        padding: 0 2rem;
        line-height: 1.7;
        color: var(--text-color);
        background: #fff;
    }
    h1, h2, h3 {
        font-family: "Iowan Old Style", "Garamond", serif;
        font-weight: normal;
        color: var(--accent-color);
    }
    nav {
        margin-bottom: 3rem;
        padding-bottom: 1rem;
        border-bottom: 1px solid #ddd;
        font-size: 0.95rem;
    }
    nav a {
        margin-right: 1.5em;
        text-decoration: none;
        color: var(--accent-color);
    }
    nav a:hover { text-decoration: underline; }
    #title { margin-bottom: 2rem; }
    #work_title { font-size: 2rem; margin-bottom: 0.5rem; }
    #toc ul { list-style: none; padding-left: 0; }
    #toc li { margin: 0.4em 0; }
    #toc a { text-decoration: none; color: #222; }
    #toc a:hover { color: var(--accent-color); }
    .greek { font-size: 1.1rem; line-height: 1.8; }
    @media (max-width: 600px) {
        body { padding: 1rem; font-size: 1.05rem; }
    }
    """
    write(joinpath(text_site_dir, "css", "style.css"), css_content)

    # Placeholder JS
    js_content = """// interactive.js — reserved for later
console.log("✅ Reader edition JS loaded for $(text_title_md)");"""
    write(joinpath(text_site_dir, "js", "interactive.js"), js_content)

    # Load templates
    template_dir = output["html_template_dir"]
    index_template_path = joinpath(template_dir, output["html_index_template"])
    index_template = read(index_template_path, String)

    # Build TOC
    toc_html = generate_toc_html(html_temp_dir, file_name)

    # Process Markdown at build time
    # 1. text_title (Markdown → HTML)
    title_html = Markdown.html(Markdown.parse(text_title_md))

    # 2. frontmatter (already in config; populates <div id="text">)
    frontmatter_md_path = output["md_frontmatter"]
    frontmatter_html = isfile(frontmatter_md_path) ?
        Markdown.html(Markdown.parse(read(frontmatter_md_path, String))) :
        "<p><em>Frontmatter will appear here.</em></p>"

    # 3. bibliography (new)
    bibliography_md_path = output["md_bibliography"]
    bibliography_html = isfile(bibliography_md_path) ?
        Markdown.html(Markdown.parse(read(bibliography_md_path, String))) :
        "<p><em>Bibliography will appear here.</em></p>"

    # Navigation (Editions Home + forward to first chunk)
    txt_files = sort(filter(f -> endswith(lowercase(f), ".txt"), readdir(html_temp_dir)))
    if isempty(txt_files)
        error("No chunked .txt files found in $(html_temp_dir)")
    end
    first_chunk_base = replace(first(txt_files), r"\.txt$"i => "")
    first_page_href = "pages/" * first_chunk_base * ".html"

    navigation_html = """
    <a href="../index.html">Editions Home</a>
    <a href="$(first_page_href)" style="float: right; font-weight: bold;">→ Start Reading</a>
    """

    # Fill template
    filled = index_template
    filled = replace(filled, "{{title}}" => title_html)           # Markdown title
    filled = replace(filled, "{{navigation}}" => navigation_html)
    filled = replace(filled, "{{frontmatter}}" => frontmatter_html)  # → <div id="text">
    filled = replace(filled, "{{bibliography}}" => bibliography_html) # → <div id="bibliography">
    filled = replace(filled, "{{generated_toc}}" => toc_html)

    # (passage_span placeholder is no longer replaced — it can safely remain in the template
    # or be removed from the template; either way it will just stay as literal text if present)

    # Fix CSS/JS paths for index.html (root level)
    filled = replace(filled, "../css/style.css" => "css/style.css")
    filled = replace(filled, "../js/interactive.js" => "js/interactive.js")

    # Write the index
    write(index_path, filled)

    println("✅ Index page fully updated at: $(index_path)")
    println("   • Title (Markdown) → HTML")
    println("   • Frontmatter (Markdown) → <div id=\"text\">")
    println("   • Bibliography (Markdown) → <div id=\"bibliography\">")
    println("   • TOC from $(length(txt_files)) chunks")
    println("   • Navigation + forward link ready")
    println("\nOpen index.html in your browser and check the new sections!")
    println("Ready for the per-chunk reader pages whenever you are.")
end

main()