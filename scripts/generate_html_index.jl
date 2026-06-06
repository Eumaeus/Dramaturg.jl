# scripts/generate_html_index.jl
# Now copies production CSS/JS from editions/templates/ (instead of placeholders)

using TOML
using Markdown
using Dramaturg

# Compatible regex escape for all Julia 1.x versions
function regex_escape(s::AbstractString)::String
    replace(s, r"([\\^\$.|?*+()[\]{}])" => s"\\\1")
end

function get_citation(chunk_base::String, file_name::String)::String
    pattern = Regex("^" * regex_escape(file_name) * "_?")
    replace(chunk_base, pattern => "")
end

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

function main()
    config_path = joinpath(@__DIR__, "config.toml")
    config = TOML.parsefile(config_path)

    Dramaturg.chunk_for_html_edition(config)

    input = config["input"]
    output = config["output"]

    file_name = input["file_name"]
    text_title_md = input["text_title"]

    html_temp_dir = output["html_temp_dir"]
    pages_dir = output["html_output_dir"]
    text_site_dir = dirname(pages_dir)
    index_path = joinpath(text_site_dir, "index.html")

    # Ensure directories
    mkpath(text_site_dir)
    mkpath(pages_dir)
    mkpath(joinpath(text_site_dir, "css"))
    mkpath(joinpath(text_site_dir, "js"))

    # === COPY TEMPLATED ASSETS (new) ===
    template_dir = output["html_template_dir"]
    cp(joinpath(template_dir, "css", "style.css"),
       joinpath(text_site_dir, "css", "style.css"),
       force = true)
    cp(joinpath(template_dir, "js", "interactive.js"),
       joinpath(text_site_dir, "js", "interactive.js"),
       force = true)

    # Load templates
    template_dir = output["html_template_dir"]
    index_template_path = joinpath(template_dir, output["html_index_template"])
    index_template = read(index_template_path, String)

    # Build TOC, Markdown → HTML, navigation, etc. (unchanged from your current version)
    toc_html = generate_toc_html(html_temp_dir, file_name)

    # Title
    title_html = Markdown.html(Markdown.parse(text_title_md))
    page_title = replace(title_html, r"<[^>]+>" => "") # for the page-title, we dont' want markup.

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

    println("✅ Index + assets copied from templates")
    println("   • CSS → $(text_site_dir)/css/style.css")
    println("   • JS  → $(text_site_dir)/js/interactive.js")
    println("   • Index page: $(index_path)")
    println("Ready for reader pages!")
end

main()