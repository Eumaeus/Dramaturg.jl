# Morphology Library

The file `morphology_library.tsv` is a growing body of unique morphological parsings. Each row consists of:

| surface-form | lemma    | pos-tag   | lexical-urn                         |
|--------------|----------|-----------|-------------------------------------|
| lu/omen      | lu/w     | v1ppia--- | urn:cite2:hmt:lsj.chicago_md:n64316 |
| ai)ti/ou     | ai)/tios | a-s---mgp | urn:cite2:hmt:lsj.chicago_md:n2777  |
| eu)=         | eu)=     | d-------- | urn:cite2:hmt:lsj.chicago_md:n43309 |

By default, `lexical-urn` will be a link to the [CITE LSJ Lexicon](https://github.com/Eumaeus/cite_lsj_cex). It is possible that there may be other sources of lexical validation that are citable by CITE2-URN.

As new texts are parsed, new triplets will be added.

"Uniqueness" consists of the identity of all four fields:

	surface-form && lemma && pos-tag && lexical-urn

Eventually, `morphology_library.tsv` will be published in its own GitHub repository.