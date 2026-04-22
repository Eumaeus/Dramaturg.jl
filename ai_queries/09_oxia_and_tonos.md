You are helping me with a project to generate thoroughly annotated online texts in Ancient Greek for readers. The project repository is up-to-date at: <https://github.com/Eumaeus/Dramaturg.jl/tree/main>.

In the directory `ai_queries` are the queries that got us to the present state of the project, including output from the most recent run of the script `examples/tokenize_demo.jl`. File `ai_queries/08_roadmap.md` is mainly for my own thinking, but it gives the current state of my thinking about where I hope this project will go.

I need help with a perpetual problem, that of the monotonic Greek *tonos* vs. the polytonic Greek *oxia*. 

Good digital editions of ancient Greek texts, and good polytonic keyboard input systems, will produce `έ` (GREEK SMALL LETTER EPSILON WITH OXIA) `U+1F73`. This is different from `έ` (GREEK SMALL LETTER EPSILON WITH TONOS) `U+03AD`.

But when you decompose `U+1F73` using `Unicode.normalize(s, :NFD)`, and recompose it, you get `U+03AD`. We do this in our code in file `src/tokenizer.jl`, lines 41-45:

```
function normalize_grave_to_acute(s::String)::String
    nfd = Unicode.normalize(s, :NFD)
    replaced = replace(nfd, '\u0300' => '\u0301')
    return Unicode.normalize(replaced, :NFC)
end
```

The problem is this. The source text will use combined characters with an oxia, but any change we make using the Unicode library will have a tonos. 

In the source text, and the derived tokenized edition, `δέ` (for example) is completely consistent. But in the file `data/indexes/frogs-speech-speaker_word_histogram.tsv`, where we have normalized grave-accents to acute accents, we see entries for both `δέ` and `δέ`

```
97	δέ	urn:cts:greekLit:tlg0019.tlg009.fu.sp:23.1.text.token.7, …
89	δέ	urn:cts:greekLit:tlg0019.tlg009.fu.sp:4.1.text.token.2, …
```

I think that in my BetaReader.jl library (<https://github.com/Eumaeus/BetaReader.jl>) I brute-force "solved" this with a final find-and-replace pass to catch each vowel with a combined tonos and replace it with that vowel with a combined oxia. 

(Vowels with combinations of diacriticals—GREEK SMALL LETTER EPSILON WITH DASIA AND OXIA, for example—are fine.)

What is the best way to deal with this and have consistency across all data, starting with the original edition?