using Test
using Dramaturg   # This brings in describe_pos (once you export it)

@testset "Morphology: describe_pos" begin



    @testset "Basic examples (exactly as requested)" begin
        @test describe_pos("v3sfim---", "ai)sqa/nomai"; markdown=false) ==
              "αἰσθάνομαι: Verb. Future indicative middle, 3rd person singular."

        @test describe_pos("a-s---fnp", "ai)/tios") ==
              "**αἴτιος**: Adjective. Feminine accusative singular."

        @test describe_pos("n-s---fa-", "ai)ti/a") ==
              "**αἰτία**: Noun. Feminine accusative singular."
    end

    #=

    @testset "Verbs – full coverage of tenses, moods, voices, persons, numbers" begin
        # Present indicative active
        @test describe_pos("v3spia---", "paideu/w"; markdown=false) ==
              "παιδεύω: Verb. Present indicative active, 3rd person plural."

        # Aorist infinitive middle
        @test describe_pos("v--a---m", "paideu/sasqai") ==
              "**παιδεύσασθαι**: Verb. Aorist infinitive middle."

        # Future optative passive (rare but valid)
        @test describe_pos("v3sfop---", "paideuqh/somai"; markdown=false) ==
              "παιδεύσομαι: Verb. Future optative passive, 3rd person singular."
    end

    @testset "Nouns & Adjectives" begin
        @test describe_pos("n-p---ma-", "a)/nqrwpoi") ==
              "**ἄνθρωποι**: Noun. Masculine nominative plural."

        @test describe_pos("a-s---fnp", "kalh/") ==
              "**καλή**: Adjective. Feminine accusative singular."

        # Comparative & Superlative
        @test describe_pos("a-s---fnc", "kalli/wn") ==
              "**καλλίων**: Adjective (comparative). Feminine nominative singular."

        @test describe_pos("a-s---fns", "kalli/sth") ==
              "**καλλίστη**: Adjective (superlative). Feminine nominative singular."
    end

    @testset "Participles, Infinitives, and other verbals" begin
        @test describe_pos("v-p---ma-", "paideu/wn") ==
              "**παιδεύων**: Verb. Present participle active, masculine nominative singular."

        @test describe_pos("v---p---a", "paideu/ein") ==
              "**παιδεύειν**: Verb. Present infinitive active."
    end

    @testset "Other parts of speech" begin
        @test describe_pos("d--------", "kalw~s") ==
              "**καλῶς**: Adverb."

        @test describe_pos("l-s---ma-", "o(") ==
              "**ὁ**: Article. Masculine nominative singular."

        @test describe_pos("g--------", "me/n") ==
              "**μέν**: Particle."

        @test describe_pos("c--------", "kai/") ==
              "**καί**: Conjunction."
    end

    @testset "Edge cases & robustness" begin
        # Short tag (should be padded with '-')
        @test describe_pos("v3s", "ei)mi/") ==
              "**εἰμί**: Verb. Present indicative, 3rd person singular."

        # All dashes (fallback)
        @test describe_pos("--------", "ti/") ==
              "**τί**: Unknown."

        # Unknown POS char
        @test describe_pos("x-s---na-", "xyz") ==
              "**xyz**: Unknown. Neuter accusative singular."
    end

   =# 
   
    @testset "Markdown toggle works correctly" begin
        @test startswith(describe_pos("n-s---fa-", "ai)ti/a"), "**αἰτία**")
        @test !startswith(describe_pos("n-s---fa-", "ai)ti/a"; markdown=false), "**")
    end

end