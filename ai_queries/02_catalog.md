You are helping me with a project to generate thoroughly annotated online texts in Ancient Greek for readers. The project repository is up-to-date at: <https://github.com/Eumaeus/Dramaturg.jl/tree/main>.

In the directory `ai_queries` are the queries that got us to the present state of the project. 

I spoke a little too soon on the matter of catalog-generation. 

Below is the top of the file `speech-speaker.cex` that is my basic input for the `tokenize_demo.jl` script:

```
// The pound sign "#" is used as a column divider.
#!cexversion
3.0
#!citelibrary
name#Aristphanes, Frogs
urn#urn:cite2:furman:cex.2026:aristophanes_project
license#Creative Commons Attribution Share Alike

#!ctscatalog
urn#citationScheme#groupName#workTitle#versionLabel#exemplarLabel#online#lang
urn:cts:greekLit:tlg0019.tlg009.fu.sp:#line/speech/speaker,line/speech/text#Aristphanes#Frogs#Furman University#tokenized by speech#true#grc

#!ctsdata
urn:cts:greekLit:tlg0019.tlg009.fu.sp:1.1.speaker#Ξανθίας
urn:cts:greekLit:tlg0019.tlg009.fu.sp:1.1.text#Εἴπω τι τῶν εἰωθότων ὦ δέσποτα,
urn:cts:greekLit:tlg0019.tlg009.fu.sp:2.1.speaker#Ξανθίας
```

And below is the top of the current output from `tokenize_demo.jl`, the file `data/tokenized/speech-speaker_tokenized.cex`.

```
// The pound sign "#" is used as a column divider.
#!cexversion
3.0
#!citelibrary
name#Aristphanes, Frogs
urn#urn:cite2:furman:cex.2026:aristophanes_project
license#Creative Commons Attribution Share Alike
#!ctscatalog
urn#citationScheme#groupName#workTitle#versionLabel#exemplarLabel#online#lang
urn:cts:greekLit:tlg0019.tlg009.fu.sp:.token:#line/speech/speaker/token,line/speech/text/token#Aristophanes#Frogs#Furman University#a derivative of urn:cts:greekLit:tlg0019.tlg009.fu.sp:, tokenized by word and punctuation#true#grc
urn#citationScheme#groupName#workTitle#versionLabel#exemplarLabel#online#lang
urn:cts:greekLit:tlg0019.tlg009.fu.sp:#line/speech/speaker,line/speech/text#Aristphanes#Frogs#Furman University#tokenized by speech#true#grc
#!ctsdata
urn:cts:greekLit:tlg0019.tlg009.fu.sp:1.1.speaker.token.1#Ξανθίας
urn:cts:greekLit:tlg0019.tlg009.fu.sp:1.1.text.token.1#Εἴπω
urn:cts:greekLit:tlg0019.tlg009.fu.sp:1.1.text.token.2#τι
urn:cts:greekLit:tlg0019.tlg009.fu.sp:1.1.text.token.3#τῶν
```

## Request 1

The complete `#!ctscatalog` block should just be:

```
#!ctscatalog
urn#citationScheme#groupName#workTitle#versionLabel#exemplarLabel#online#lang
urn:cts:greekLit:tlg0019.tlg009.fu.sp.token:#line/speech/speaker/token,line/speech/text/token#Aristophanes#Frogs#Furman University#a derivative of urn:cts:greekLit:tlg0019.tlg009.fu.sp:, tokenized by word and punctuation#true#grc
```

(The next two lines should not be there.)

## Request 2

The URN for the text documented in this file should be:

`urn:cts:greekLit:tlg0019.tlg009.fu.sp:.token:`

The script is currently generating this (only in the `#!ctscatalog` block; the URNs under `#!ctsdata` are correct):

`urn:cts:greekLit:tlg0019.tlg009.fu.sp:.token:`

There is an extra `:` in there. (A CTS-URN that does not have a citation-element, like this URN in the catalog, is terminated with `:`. The fields of the "bibliographic hierarchy", everything after `greekLit:` should be separated by `.`.)

## Request 3

I would like a blank line before each block-header, that is, each line begining with `#!`. This will make it more easily legible for human readers.

The two indices that the demo script generates are perfect!

My next requests for help will extend indexing a little further, before we move on to morphological and lexical analysis.

------

Not quite there! The script runs smoothly, and I love the new blank lines for legibility. I have updated the project at <https://github.com/Eumaeus/Dramaturg.jl/tree/main> with the current output.

In the output file `data/tokenized/speech-speaker-tokenized.cex`, lines 14 and 15 should not be there.

The script writes:

```
#!ctscatalog
urn#citationScheme#groupName#workTitle#versionLabel#exemplarLabel#online#lang
urn:cts:greekLit:tlg0019.tlg009.fu.sp.token:#line/speech/speaker/token,line/speech/text/token#Aristophanes#Frogs#Furman University#a derivative of urn:cts:greekLit:tlg0019.tlg009.fu.sp:, tokenized by word and punctuation#true#grc
urn#citationScheme#groupName#workTitle#versionLabel#exemplarLabel#online#lang
urn:cts:greekLit:tlg0019.tlg009.fu.sp:#line/speech/speaker,line/speech/text#Aristphanes#Frogs#Furman University#tokenized by speech#true#grc
```

But it should be:

```
#!ctscatalog
urn#citationScheme#groupName#workTitle#versionLabel#exemplarLabel#online#lang
urn:cts:greekLit:tlg0019.tlg009.fu.sp.token:#line/speech/speaker/token,line/speech/text/token#Aristophanes#Frogs#Furman University#a derivative of urn:cts:greekLit:tlg0019.tlg009.fu.sp:, tokenized by word and punctuation#true#grc
```

