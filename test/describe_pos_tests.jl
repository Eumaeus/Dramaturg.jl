using Test
using Dramaturg   # This brings in describe_pos (once you export it)

@testset "Morphology: describe_pos" begin



    @testset "Basic examples" begin
        # Markdown false
        @test describe_pos("a)/nqrwpos", "a)/nqrwpos", "n-s---mn-", markdown=false) ==
              "ἄνθρωπος. From 'ἄνθρωπος'. Noun. Masculine, nominative, singular. [n-s---mn-]"
        # Markdown true
        @test describe_pos("a)/nqrwpos", "a)/nqrwpos", "n-s---mn-", markdown=true) ==
              "**ἄνθρωπος**. From **ἄνθρωπος**. Noun. Masculine, nominative, singular. [n-s---mn-]"
        # Markdown default to true
        @test describe_pos("a)/nqrwpos", "a)/nqrwpos", "n-s---mn-") ==
              "**ἄνθρωπος**. From **ἄνθρωπος**. Noun. Masculine, nominative, singular. [n-s---mn-]"


        @test describe_pos("krh/nhn", "krh/nh", "n-s---fa-") ==
              "**κρήνην**. From **κρήνη**. Noun. Feminine, accusative, singular. [n-s---fa-]"

        @test describe_pos("e)/lusa", "lu/w", "v1saia---") ==
              "**ἔλυσα**. From **λύω**. Verb. Aorist, indicative, active, 1st person, singular. [v1saia---]"

        @test describe_pos("poiw=n", "poie/w",  "v-sppamn-" ) ==
              "**ποιῶν**. From **ποιέω**. Verb. Present, participle, active, masculine, nominative, singular. [v-sppamn-]"

        @test describe_pos("poiou/menos", "poie/w", "v-sppemn-") ==
              "**ποιούμενος**. From **ποιέω**. Verb. Present, participle, middle-passive, masculine, nominative, singular. [v-sppemn-]"

        @test describe_pos("poiei=n", "poie/w", "v--pna---") ==
              "**ποιεῖν**. From **ποιέω**. Verb. Present, infinitive, active. [v--pna---]"

        @test describe_pos("a)/nqrwpoi", "a)/nqrwpos", "n-p---mn-") == "**ἄνθρωποι**. From **ἄνθρωπος**. Noun. Masculine, nominative, plural. [n-p---mn-]"


        @test describe_pos("a)/nqrwpoi", "a)/nqrwpos", "n-p---mv-") == "**ἄνθρωποι**. From **ἄνθρωπος**. Noun. Masculine, vocative, plural. [n-p---mv-]"
        
        
        @test describe_pos("a)/nqrwpos", "a)/nqrwpos", "n-s---mn-") == "**ἄνθρωπος**. From **ἄνθρωπος**. Noun. Masculine, nominative, singular. [n-s---mn-]"
        
        
        @test describe_pos("a)nqrw/pou", "a)/nqrwpos", "n-s---mg-") == "**ἀνθρώπου**. From **ἄνθρωπος**. Noun. Masculine, genitive, singular. [n-s---mg-]"

        @test describe_pos("eu)=", "eu)=", "d--------") == "**εὖ**. From **εὖ**. Adverb. [d--------]"

    end

    
   
    

end