You are helping me with a project to generate thoroughly annotated online texts in Ancient Greek for readers. The project repository is up-to-date at: &lt;https://github.com/Eumaeus/Dramaturg.jl/tree/main&gt;.

In the directory `ai_queries` are enumerated files of the queries that got us to the present state of the project. The output from the current code can be found in the directories `data` and `morph/output`, and for html editions, `editions` (which also includes template files.)

The directory `scripts` contains the scripts that constitute the current pipeline. This pipeline is described in `docs/Pipeline.md`. There are concise "recipes" specific to my three demonstration texts. The current output in `data/` is the result of me walking through each of these recipes.

The scripts of the pipeline depend on Julia code in the `src` directory.

Everything is driven from `scripts/config.toml`.

We are now working on building a "reader's edition" of a text in HTML. I have checked into GitHub selected example of the current output of `scripts/generate_html_reader_pages.jl` and `scripts/generate_html_index.jl` into `edition/` for reference.

## Next Steps

The pages look and work great, just as I'd hoped they would!

There are three obvious things for our next steps. Two are short, and the third is more complex.

### 1 `:hover` in Safari

The user interaction involving `:hover` works perfectly in Chrome. It only occasionally works in (Desktop) Safari. There is a lot of comment on `:hover` in Safari, but I have not seen anyone describe an obvious cause. I found the same problem in my earlier attempts at a UI like this. It only applies to more recent versions of desktop Safari. If you have thoughts on a fix, that would be great.

### 2 Toggle "Editor Mode"

I would like a toggle-button to turn "Editor Mode" on and off. If it is off, the user won't see the "Mark as Preferred" button.

### 3 Improved Table of Contents on `index.html`

We have a cleanly isolated function `generate_toc_html()` in `scripts/generate_html_index.jl`. I would like to improve it.

Rather than a long list of `chunk_017`, etc., I would like prefer the links to be named something like "Passages 479–502", or (in the case of a text with a 2-level cittion scheme), "Passages 1.233–1.245".

For a TOC, I think 8 items is probably as long as we want to display on the index page. So for a text that we process into <= 8 chunks, we can just display a list.

If there are more chunks, I think we need some accordion display.

For a text with a 1-level citation scheme, like the Homeric Hymn to Demeter or Aristophanes' Frogs, if there are more than 8 chunks, generated pages, we should "chunk the chunks", dividing the TOC into groups of eight. Each group would have a heading that would expand to show the eight TOC items in that group. The label of the heading would be "Passages 1–450", with the range derived from the first passage in the first page in that group, and the last passage in the last page in that group. When the heading is expanded, it would show the list of links to those eight pages.

For a text with a 2-level citation scheme, like Herodotus ("1.2" = "Book 1, section 2") or the Iliad ("1.611" = "Book 1, line 611"), the obvious solution would be to have headings for the top-level (left-most element of the citation), which expand to reveal a list of pages for Book 1, Book 2, etc.

This might change how we chunk the text. That function is handled in `src/htmleditions.jl`, with the functions `chunk_drama()` and `chunk_prose_and_poetry()`. When chunking a text with a 2-level citation scheme, we should not cros the boundary between top-level divisions. So even if we have a very short chunk from Iliad 1.600-1.611, it should cut off there, and the next chunk would begin with Iliad 2.1.

I'm sorry I didn't articulate this when we made the chunking function.

With a text like the Iliad, we would need to further divide the TOC based on both the levels of the citation. For Herodotus, we would have eight headings, one for each book, which would expand to show chunks of sections, eight at a time. For the Iliad, with 24 books, each of hundreds of lines, we would have three top-level headings: "Iliad 1-8", "Iliad 9-16" "Iliad 17-24". Each of these would reveal sub-headings for the pages containing text for those books.

I don't think we need to change the file-names of the chunk `.txt` files, or of the html pages. 'chunk_017.html' works fine.



