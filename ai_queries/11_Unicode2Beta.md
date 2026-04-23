You are helping me with a project to generate thoroughly annotated online texts in Ancient Greek for readers. The project repository is up-to-date at: <https://github.com/Eumaeus/Dramaturg.jl/tree/main>.

In the directory `ai_queries` are the queries that got us to the present state of the project, including output from the most recent run of the script `examples/tokenize_demo.jl`.

The latest addition was code to generate a vocabulary list in `/data/vocabulary/`. That code works great.

I now need to use the BetaReader.jl library to convert that vocabulary list to BetaCode, since that is what the Morpheus parser expects.

While we are at it, it would be useful to have a utility script that exists solely to read a text in Unicode Greek and export a verson in BetaCode, and vice-versa. 

And the `examples/tokenize_demo.jl` is starting to transcend "demo" and be a substantial tool in this project. This might be a good time, in general, to think about how best to organize the relationship between the code in `src` and the scripts that will invoke it.

----

"Write the exact diff/patch for src/vocabulary.jl + Dramaturg.jl?" would be great!

The batch-processing in Morpheus has to run in a Docker instance, and I have that script ready to move into place. 

This refactor looks good. I need to remember to add the exports to `Dramaturg.jl`, which I will do now.