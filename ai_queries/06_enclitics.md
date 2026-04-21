You are helping me with a project to generate thoroughly annotated online texts in Ancient Greek for readers. The project repository is up-to-date at: <https://github.com/Eumaeus/Dramaturg.jl/tree/main>.

In the directory `ai_queries` are the queries that got us to the present state of the project.

Okay, that looks great! The code runs perfectly. For my part, I only now realize that I omitted a step in my thinking.

For indexing, histograms, and any other list-making we do, but **not** for the tokenized edition, we need to "normalize" grave accents.

That is, when generating a list, histogram, or index, `καὶ` and `καί` should be treated as the same word, and rendered with an acute accent: `καί`. We never lose the surface-forms with the grave, since the token-level CTS-URN will always point us back to the true text-content of the citable passage in the text.

This was my omission… it would probably have been easier to implement this earlier.

It is traditional, when talking about enclitics, particularly two-syllable enclitics, to give the word an acute accent on the final syllable, the "ultima". So while "he is" may appear as `ἐστι`, with no accent, in the text, we would write, e.g., "The third person singular of 'to be' is ἐστί." 

I have added `source-data/editorial-dict-enclitics.tsv` to contain a growing list of these cases. There is a column for `surface_form` and one for `presentation_form`. The list will grow, but there are not that many such forms.

Along these same lines, I have added `source-data/editorial_dict_anastrophe.tsv` containing bisyllabic prepositions whose accent will move from the ultima, where it normally falls, to the penult, when the preposition follows its object.

These, too, should appear in their `presentation_form` in indexes and histograms. The token-level CTS-URN will point to the form as it appears in the text. (If we want to index instances of anastrophe, that will be easy enough to generate from the tokenized edition.)

---

While using Unicode is clearly present in tokenize.jl, I get Jula errors:


```
Precompiling Dramaturg finished.
  0 dependencies successfully precompiled in 1 seconds. 91 already precompiled.

ERROR: LoadError: The following 1 direct dependency failed to precompile:

Dramaturg 

Failed to precompile Dramaturg [f5e8a5c5-9f0a-4b0a-8e0a-5f5e5f5e5f5e] to "/Users/cblackwell/.julia/compiled/v1.12/Dramaturg/jl_xrf94g".
ERROR: LoadError: ArgumentError: Package Dramaturg does not have Unicode in its dependencies:
- You may have a partially installed environment. Try `Pkg.instantiate()`
  to ensure all packages in the environment are installed.
- Or, if you have Dramaturg checked out for development and have
  added Unicode as a dependency but haven't updated your primary
  environment's manifest file, try `Pkg.resolve()`.
- Otherwise you may need to report an issue with Dramaturg
Stacktrace:
 [1] top-level scope
   @ ~/Dropbox/CITE/grok/Dramaturg/src/Dramaturg.jl:10
 [2] top-level scope
   @ stdin:5
in expression starting at /Users/cblackwell/Dropbox/CITE/grok/Dramaturg/src/tokenizer.jl:1
in expression starting at /Users/cblackwell/Dropbox/CITE/grok/Dramaturg/src/Dramaturg.jl:1
in expression starting at stdin:
in expression starting at /Users/cblackwell/Dropbox/CITE/grok/Dramaturg/examples/tokenize_demo.jl:1
```

---

I made the suggested changes, and ran `julia; ] instantiate`. Julia still complains that Unicode is not present. I have checked the current state of all files into GitHub at <https://github.com/Eumaeus/Dramaturg.jl/tree/main>.

The error report is:

```
 Dramaturg git:(main) ✗ julia --project=. examples/tokenize_demo.jl                          
Info Given Dramaturg was explicitly requested, output will be shown live 
ERROR: LoadError: ArgumentError: Package Unicode [4ec3a0c8-7d5a-4d6a-9f5a-6f5b5f5e5f5e] is required but does not seem to be installed:
 - Run `Pkg.instantiate()` to install all recorded dependencies.

Stacktrace:
 [1] top-level scope
   @ ~/Dropbox/CITE/grok/Dramaturg/src/Dramaturg.jl:7
 [2] top-level scope
   @ stdin:5
in expression starting at /Users/cblackwell/Dropbox/CITE/grok/Dramaturg/src/Dramaturg.jl:1
in expression starting at stdin:5
  ✗ Dramaturg
Precompiling Dramaturg finished.
  0 dependencies successfully precompiled in 1 seconds. 91 already precompiled.

ERROR: LoadError: The following 1 direct dependency failed to precompile:

Dramaturg 

Failed to precompile Dramaturg [f5e8a5c5-9f0a-4b0a-8e0a-5f5e5f5e5f5e] to "/Users/cblackwell/.julia/compiled/v1.12/Dramaturg/jl_BDijgU".
ERROR: LoadError: ArgumentError: Package Unicode [4ec3a0c8-7d5a-4d6a-9f5a-6f5b5f5e5f5e] is required but does not seem to be installed:
 - Run `Pkg.instantiate()` to install all recorded dependencies.

Stacktrace:
 [1] top-level scope
   @ ~/Dropbox/CITE/grok/Dramaturg/src/Dramaturg.jl:7
 [2] top-level scope
   @ stdin:5
in expression starting at /Users/cblackwell/Dropbox/CITE/grok/Dramaturg/src/Dramaturg.jl:1
in expression starting at stdin:
in expression starting at /Users/cblackwell/Dropbox/CITE/grok/Dramaturg/examples/tokenize_demo.jl:1
➜  Dramaturg git:(main) ✗ 
```

---

Hmmm. Now we get this:

```
(Dramaturg) pkg> add Unicode
    Updating registry at `~/.julia/registries/General.toml`
   Resolving package versions...
ERROR: expected package `Unicode [4ec3a0c8]` to be registered
```
