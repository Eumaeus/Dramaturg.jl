# Formatting Commentary Texts

Commentary texts are in the form of `.tsv` files.

Each file consists of records.

Each record is a single line in the text file:

`cts-urn` `<tab>` `markdown-commentary`

The CTS-URN can be to a token-node or to a citation-unit:

- Token-node: `urn:cts:greekLit:tlg0019.tlg009.fu.sp:13.1.text.token.5`
- Citation unit: `urn:cts:greekLit:tlg0019.tlg009.fu.sp:13.1`

The commentary, after the tab, can use Markdown formatting. To divide into paragraphs, use `<p>…</p>`. But it must remain all one tab-delimited line.


