You are helping me with a project to generate thoroughly annotated online texts in Ancient Greek for readers. The project repository is up-to-date at: <https://github.com/Eumaeus/Dramaturg.jl/tree/main>.

In the directory `ai_queries` are the queries that got us to the present state of the project, including output from the most recent run of the script `examples/tokenize_demo.jl`. File `ai_queries/08_roadmap.md` is mainly for my own thinking, but it gives the current state of my thinking about where I hope this project will go.

Today, I would like to do one last step before moving on to including morphological information indexed to our text. We need a simple "vocabulary list." This should be easy, based on the indexing we are already doing.

Working from the word-histogram file, e.g. `data/indexes/frogs-speech-speaker_word_histogram.tsv`, let's make a plain-text vocabulary file. This would just be the contents of the second column, `form`, and nothing else. Since the forms are now nicely normalized, unelided, with acute accents (oxia!), and unqued, this will give me a perfect text file to feed into the morphological parser.

The histogram currently includes punctuation marks, which are of course their own tokens and represent interesting information. For the vocabulary list we should omit them.

I have edited a few times the regular expression that catches punctuation when tokenizing. Its current state is at line 41 of `src/tokenizer.jl`:

`text = replace(text, r"([-“”\"·.,;:!?{}…()[\]])" => s" \1 ")`

If we are going to use that in a few places, perhaps we should refactor it out?