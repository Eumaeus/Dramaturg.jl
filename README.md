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

