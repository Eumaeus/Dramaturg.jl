You are helping me with a project to generate thoroughly annotated online texts in Ancient Greek for readers. The project repository is up-to-date at: <https://github.com/Eumaeus/Dramaturg.jl/tree/main>.

In the directory `ai_queries` are the queries that got us to the present state of the project.

I have gone over the data resulting from our code so far, and there are a few things to fix. I'll take them one at a time.

## 1

The function `tokenize_line()` was not catching the typographers' quotation marks `“”` in the text; they were retained with the word they preceded or followed. I made the following edit to the function, in file `tokenizer.jl` and that seems to work.

```
function tokenize_line(text::String)
    # Insert space before common Greek punctuation so they become their own tokens
    text = replace(text, r"([“”·,.;:!?()[\]])" => s" \1 ")
    # Split on whitespace, drop empty tokens
    tokens = split(text, r"\s+"; keepempty=false)
    return tokens
end
```

I have checked in that change to GitHub.

## 2

Something is not working in the function for extracting an index and histogram of elided forms.

In the current output, in file `data/indexes/speech-speaker_elided.tsv`, the output of the `tokenize_demo.jl` script, line 1496 shows this: `ἰὴ κόπον οὐ πελάθεις ἐπʼ ἀρωγάν;`

Likewise line 63: `Ἴακχʼ ὦ Ἴακχε.`

Looking in output file `speech-speaker_elided_histogram.tsv`, at output line 32 we see this:

```
5	ἰὴ κόπον οὐ πελάθεις ἐπʼ ἀρωγάν;		urn:cts:greekLit:tlg0019.tlg009.fu.sp:1265.1.text,urn:cts:greekLit:tlg0019.tlg009.fu.sp:1267.1.text,urn:cts:greekLit:tlg0019.tlg009.fu.sp:1271.1.text,urn:cts:greekLit:tlg0019.tlg009.fu.sp:1275.1.text,urn:cts:greekLit:tlg0019.tlg009.fu.sp:1277.1.text
```

For comparison, line 31, which is correct, is:

```
5	ἄρʼ		urn:cts:greekLit:tlg0019.tlg009.fu.sp:19.1.text.token.3,urn:cts:greekLit:tlg0019.tlg009.fu.sp:795.1.text.token.3,urn:cts:greekLit:tlg0019.tlg009.fu.sp:921.1.text.token.5,urn:cts:greekLit:tlg0019.tlg009.fu.sp:1195.2.text.token.2,urn:cts:greekLit:tlg0019.tlg009.fu.sp:1517.1.text.token.5
```

For some reason, line 5 seems to be pulling data from the original CEX file, `working-files/speech-speaker.cex`, rather than from the tokenized derivative, `data/tokenized/speech-speaker_tokenized.cex`. We can see this from, first, the fact that it is a whole line of poetry, and second, that it cites URNs to the un-tokenized text.

I have looked at the code in `tokenizer.jl` and cannot see how this is happening. 

I would value your thoughts. 

And while we are at it, if you could sketch out a test for `tokenize_line()`, I could use that to start building a set of tests to confirm that tokenization is working correctly.

I