module Dramaturg

# Public API
export read_config, load_cex, tokenize_to_exemplar, generate_elision_index,
       generate_word_histogram, get_output_path, write_tokenized_cex, tokenize_line

# Load our new sub-modules
include("config.jl")
include("cex_loader.jl")
include("tokenizer.jl")

"""
    Dramaturg.version()
Return the current package version.
"""
function version()
    return pkgversion(Dramaturg)
end

println("Dramaturg.jl v$(version()) loaded — ready for CEX → tokenized exemplar + elision indices!")

end # module