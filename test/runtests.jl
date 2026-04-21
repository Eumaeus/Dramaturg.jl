using Dramaturg
using Test

@testset "Dramaturg.jl" begin
    @test Dramaturg.version() isa VersionNumber
    # Add more tests as we build functions
    println("✅ All tests passed (skeleton)")
end

@testset "tokenize_line" begin
    @test tokenize_line("") == String[]
    @test tokenize_line("   ") == String[]

    # Basic Greek with punctuation
    @test tokenize_line("ἄρʼ εἰσὶν ἄνδρες;") == ["ἄρʼ", "εἰσὶν", "ἄνδρες", ";"]

    # Typographers’ quotes (the fix you just added)
    @test tokenize_line("“ἰὴ κόπον” οὐ πελάθεις ἐπʼ ἀρωγάν;") ==
          ["“", "ἰὴ", "κόπον", "”", "οὐ", "πελάθεις", "ἐπʼ", "ἀρωγάν", ";"]

    # Elision apostrophe must stay attached (never split)
    @test tokenize_line("ἐπʼ αὐτὸν καὶ τὸν Ἴακχʼ ὦ Ἴακχε.") ==
          ["ἐπʼ", "αὐτὸν", "καὶ", "τὸν", "Ἴακχʼ", "ὦ", "Ἴακχε", "."]

    # Multiple spaces, mixed punctuation
    @test tokenize_line("ἄνδρες· καὶ γυναῖκες! (ἐν τῇ πόλει).") ==
          ["ἄνδρες", "·", "καὶ", "γυναῖκες", "!", "(", "ἐν", "τῇ", "πόλει", ")", "."]

   # Brackets and ellipses
    @test tokenize_line("ἄνδρες· [καὶ γυναῖκες]! (ἐν {τῇ} πόλει) […].") ==
          ["ἄνδρες", "·", "[", "καὶ", "γυναῖκες", "]", "!", "(", "ἐν", "{", "τῇ", "}", "πόλει", ")", "[", "…", "]", "."]


    # Only punctuation
    @test tokenize_line("· ; ! ?") == ["·", ";", "!", "?"]
end