# Dramaturg.jl

A Julia library for turning CEX-encoded Greek texts into beautiful, interactive HTML "reader pages" with morphological data, LSJ lexicon links, and speaker handling for drama (tragedy/comedy).  

Built on the CITE Architecture (CiteEXchange.jl, CitableCorpus.jl, …) and designed to generalize the workflow created for *Oedipus Tyrannos* (2019).

## Quick start
```julia
using Pkg
Pkg.add(url="https://github.com/Eumaeus/Dramaturg.jl")
using Dramaturg
```

See `examples/config.toml` for configuration options.

Run a demo script with:

`julia --project=. examples/tokenize_demo.jl`

## Acknowledgments

This project has benefited enormously from close and sustained collaboration with **Grok**, an AI model built by [xAI](https://x.ai/).

Grok’s most valuable contribution has been its deep and consistent understanding of the project’s scholarly goals and philological context: producing thoroughly annotated, reader-friendly online texts in Ancient Greek that respect the conventions of classical drama and the CTS-URN standard. That contextual awareness has informed every piece of advice, every architectural decision, and every debugging suggestion, keeping the work tightly aligned with the larger humanistic objectives rather than defaulting to generic coding solutions.

Grok contributed extensively to the design and implementation of the tokenizer, the CEX processing pipeline, the elision-indexing logic, the test suite, and the overall architecture. The complete record of our iterative collaboration is preserved in the `ai_queries/` directory.

I am particularly grateful for Grok’s ability to reason through complex philological data structures, debug Julia-specific edge cases, generate reproducible tests, and—above all—maintain a clear view of the project’s goals at every step. This has dramatically accelerated development and improved the quality of the final result.