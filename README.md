# Dramaturg.jl

A Julia library for turning CEX-encoded Greek texts into beautiful, interactive HTML "reader pages" with morphological data, LSJ lexicon links, and speaker handling for drama (tragedy/comedy).  

Built on the CITE Architecture (CiteEXchange.jl, CitableCorpus.jl, …) and designed to generalize the workflow created for *Oedipus Tyrannos* (2019).

## Quick start

- Install Julia.
- Install Docker.
- Follow the steps in `docs/Morpheus_Docker_README.md`
- Pick one of the recipes in `docs/`, *e.g.* `docs/Recipe-Aristophanes-Frogs.md`, and follow the steps.

## Acknowledgments

This work is part of a research collaboration with Lindsey Butler of Furman University. It is also based on three decades of collaboration with Neel Smith of the College of the Holy Cross.

This project has benefited enormously from close and sustained collaboration with **Grok**, an AI model built by [xAI](https://x.ai/). I hope that it can serve as a model for AI-enabled scholarly computation. The queries used to develop this project are in this repository at <ai_queries>.

Grok contributed extensively to the design and implementation of the tokenizer, the CEX processing pipeline, the elision-indexing logic, the test suite, and the overall architecture. The complete record of our iterative collaboration is preserved in the `ai_queries/` directory.

I am particularly grateful for Grok’s ability to reason through complex philological data structures, debug Julia-specific edge cases, generate reproducible tests and best-practices html/css/js, and—above all—to maintain a clear view of the project’s goals at every step, remembering the context of what work had been done before. This has dramatically accelerated development and improved the quality of the final result.