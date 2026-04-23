You are helping me with a project to generate thoroughly annotated online texts in Ancient Greek for readers. The project repository is up-to-date at: <https://github.com/Eumaeus/Dramaturg.jl/tree/main>.

In the directory `ai_queries` are the queries that got us to the present state of the project, including output from the most recent run of the script `examples/tokenize_demo.jl`.

The code is now generating good vocabulary files in both Unicode and Betacode.

I did a certain amount of refactoring involving `src/config.jl`, `src/tokenizer.jl`, `examples/tokenize_demo.jl`, and `examples/config.toml`:

- There were some hard-coded filenames and filepaths. Those are now all generated from the `examples/config.toml`. 
- BetaReader evidently doesn't handle the elision-marks properly (at least not the ones in my texts), so I added a little text-replacement after reading in any Unicode to get those into a form that will transliterate properly. (Elision marks and the Greek semi-colon are sources of chaos when people type digital editions of Greek.)

All of these changes are checked in, along with script output from my main focus, Aristophanes *Frogs*, and my two other test texts, Herodotus and the Homeric Hymn to Demeter.

This is just an after-action report, mainly for my own record. You have noted that the contents of `ai_queries` is serving as my log, or diary, of the development of this project, to give both you and me context as we move forward.