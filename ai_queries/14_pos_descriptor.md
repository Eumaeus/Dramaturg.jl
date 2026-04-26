You are helping me with a project to generate thoroughly annotated online texts in Ancient Greek for readers. The project repository is up-to-date at: <https://github.com/Eumaeus/Dramaturg.jl/tree/main>.

In the directory `ai_queries` are the queries that got us to the present state of the project, including output from the most recent run of the script `examples/tokenize_demo.jl`.

## Updates

All of this is checked into GitHub at <https://github.com/Eumaeus/Dramaturg.jl/tree/main>.

## Requests for Help

The next thing will be to add a function to `src/morphology.jl` that:

- Takes a POS-tag (String) and Lemma (String) as input, and
- Returns a human-readable description. Greek should be translated back into Unicode for this human-readable display.
- In the perfect world there would be a 'markdown=true' parameter.

Example of what I have in mind…

ai)sqh/setai	ai)sqa/nomai	v3sfim---
ai)ti/an	ai)/tios	n-s---fa-
ai)ti/an	ai)ti/a n-s---fa-


```julia

# Example 1

pos = "v3sfim---"
lemma = "ai)sqa/nomai"
markdown = false

describe_pos(pos, lemma, markdown) == "aἰσθάνομαι: Verb. Future indicative middle, 3rd person singular."

# Example 2

pos = "a-s---fnp"
lemma = "ai)/tios"
markdown = true

describe_pos(pos, lemma, markdown) == "**αἴτιος**: Adjective (positive). Feminine accusative singular."

# Example 3

pos = "n-s---fa-"
lemma = "ai)ti/a"

describe_pos(pos, lemma) == "**αἰτία**: Noun. Feminine accusative singular." # Let's default the `markdown` parameter to `true`. Easy to change later if I hate it that way.

```

One use of this will be to create some test-sets of vocabulary to verify that Morpheus-> POS parsing is working properly.

----

That looks great! 

Perhaps, as one last step, you could help me set up a tidy couple of unit-tests that I could use as the basis for testing a wide range of POS tags against the current code? I like to do the "write the test, then code to the test" approach. I have one test-file at `tests/runtests.jl`. This might be a good time for a second, specific `describe_pos_tests.jl` test-suite.
