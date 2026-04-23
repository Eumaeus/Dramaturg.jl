module Dramaturg


# Public API
export read_config, load_cex
export generate_elision_index, generate_word_histogram, get_output_path
export write_tokenized_cex, tokenize_line, generate_vocabulary
export normalize_grave_to_acute, get_presentation_form, tokenize_to_exemplar 

using Unicode   # ← new import for robust accent normalization


# Load our new sub-modules
include("config.jl")
include("cex_loader.jl")
include("tokenizer.jl")
include("vocabulary.jl")

"""    Dramaturg.version()
Return the current package version.
"""
function version()
    return pkgversion(Dramaturg)
end

println("Dramaturg.jl v$(version()) loaded — ready for CEX → tokenized exemplar + elision indices!")

end # module