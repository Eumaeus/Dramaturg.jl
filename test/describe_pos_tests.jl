using Test
using Dramaturg   # This brings in describe_pos (once you export it)

@testset "Morphology: describe_pos" begin



    @testset "Basic examples" begin
        # Markdown false
        @test describe_pos("a)/nqrwpos", "a)/nqrwpos", "n-s---mn-", markdown=false) ==
              "ἄνθρωπος. From ‘ἄνθρωπος’. Noun. Masculine, nominative, singular. [n-s---mn-]"
        # Markdown true
        @test describe_pos("a)/nqrwpos", "a)/nqrwpos", "n-s---mn-", markdown=true) ==
              "**ἄνθρωπος**. From ‘**ἄνθρωπος**’. Noun. Masculine, nominative, singular. [n-s---mn-]"
        # Markdown default to true
        @test describe_pos("a)/nqrwpos", "a)/nqrwpos", "n-s---mn-") ==
              "**ἄνθρωπος**. From ‘**ἄνθρωπος**’. Noun. Masculine, nominative, singular. [n-s---mn-]"


        @test describe_pos("krh/nhn", "krh/nh", "n-s---fa-") ==
              "**κρήνην**. From ‘**κρήνη**’. Noun. Feminine, accusative, singular. [n-s---fa-]"

        @test describe_pos("e)/lusa", "lu/w", "v1saia---") ==
              "**ἔλυσα**. From ‘**λύω**’. Verb. Aorist, indicative, active, 1st person, singular. [v1saia---]"

        @test describe_pos("poiw=n", "poie/w", "v-spapmn-") ==
              "**ποιῶν**. From ‘**ποιέω**’. Verb. Present, participle, active, masculine, nominative, singular. [v-spapmn-]"

        @test describe_pos("poiou/menos", "poie/w", "v-spepmn-") ==
              "**ποιῶν**. From ‘**ποιέω**’. Verb. Present, participle, middle-passive, masculine, nominative, singular. [v-spepmn-]"

         @test describe_pos("poiei=n", "poie/w", "v--pna---") ==
              "**ποιεῖν**. From ‘**ποιέω**’. Verb. Present, infinitive, active. [v--pna---]"
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
   
    

end