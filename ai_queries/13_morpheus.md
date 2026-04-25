You are helping me with a project to generate thoroughly annotated online texts in Ancient Greek for readers. The project repository is up-to-date at: <https://github.com/Eumaeus/Dramaturg.jl/tree/main>.

In the directory `ai_queries` are the queries that got us to the present state of the project, including output from the most recent run of the script `examples/tokenize_demo.jl`.

## Updates

1. I added code in `examples.config.toml` and `src/tokenizer.jl` to allow filtering out paratext based on values in the URN fields. In this case, I wanted to omit any URN with "speaker" in it, so the histogram and vocabulary lists do not include speaker-attributions. Currently that parameter is a single string, but eventually, it would probably be good to allow an array of strings. The `src/tokenizer.jl` code would have to change, but that should be a one-liner.
1. I have added a directory `Dramaturg/morph`. In that directory is a README, `Dramaturg/morph/README.md` that outlines the steps for:
	- installing the Docker desktop app
	- running a VM containing the legacy Morpheus Greek parser
	- parsing individual Greek words
	- batch-parsing words in `Dramaturg/morph/source-data/words.txt` to output and an error log that will appear in `Dramaturg/morph/output/`.
1. Also in that directory are `morph/test-data` and `morph/test-output`, for a hand-curated set of forms to test this process and subsequent steps based on data from this process.
1. I have added a directory `webapps` that currently contains one html/css/js application that lets users generate a POS-tag by choosing options from a series of popup menus. So the user selects "noun", "femininte", "accusative", "plural", and the app generates `n-p---fa-`. This will be useful, possibly, for me and other users. Its code (JS compiled with ScalaJS) might also be helpful as we work to perfect the generation of pos-tags from Morpheus data.

All of this is checked into GitHub at <https://github.com/Eumaeus/Dramaturg.jl/tree/main>.

## Requests for Help

1. I would value your expert advice on the current structure of the repository. I am expecting this one project to do a lot, so it will be especially important for me to have things well-organized.
2. I would like translate the Morpheus output, for example `morph/output/analysis.txt` into triplets of: surface-form, lemma, and POS-tag:

```
ai)sqh/setai	ai)sqa/nomai	v3sfim---
ai)ti/an	ai)/tios	n-s---fa-
ai)ti/an	ai)ti/a n-s---fa-
```

------

Thank you for the excellent suggestions! The `working-files` should not be in the Git repository, and I will remove it. I will implement all of your other suggestions, gratefully.

Earlier in this thread I said:

> 2. I would like translate the Morpheus output, for example `morph/output/analysis.txt` into triplets of: surface-form, lemma, and POS-tag:

```
ai)sqh/setai	ai)sqa/nomai	v3sfim---
ai)ti/an	ai)/tios	n-s---fa-
ai)ti/an	ai)ti/a n-s---fa-
```

I think I need to expland on this.

Here is what the actual Morpheus output for those three forms looks like:

```
ai)sqh/setai
<NL>V ai)sqa/nomai  fut ind mid 3rd sg			reg_fut,anw</NL>
```

…and…

```
ai)ti/an
<NL>N ai)ti/a_n,ai)/tios  fem acc sg	attic doric aeolic		os_h_on</NL><NL>N ai)ti/a_n,ai)ti/a  fem acc sg	attic doric aeolic		h_hs</NL>
```

So it is non-trivial to turn these analyses into Perseus-style POS-tags. You helped me get started some months ago, and this was where we got: <https://raw.githubusercontent.com/Eumaeus/pos-julia/refs/heads/main/parse_morpheus.jl>

Does this clarify the next step?

----

Wonderful! Thank you! I will do a little housekeeping and knock off until tomorrow, when I can test this code with a clear mind. Your help is invaluable.
