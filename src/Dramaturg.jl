module Dramaturg


# Public API (we'll flesh these out next)
export read_config, tokenize, align_morphology, align_lsj, generate_reader_pages

# Placeholder for future sub-modules (keeps the code organized)
# include("config.jl")
# include("tokenize.jl")
# include("morphology.jl")
# include("lexicon.jl")
# include("html_generator.jl")
# include("editor.jl")      # future
# include("syntax.jl")      # future

"""
        Dramaturg.version()
"""
function version()
    return pkgversion(Dramaturg)
end

println("Dramaturg.jl v$(version()) loaded — ready for CEX → HTML readers!")

end # module