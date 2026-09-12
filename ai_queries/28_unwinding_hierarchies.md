You are helping me with a project to generate thoroughly annotated online texts in Ancient Greek for readers. The project repository is up-to-date at: <https://github.com/Eumaeus/Dramaturg.jl/tree/main>.

Do not read the whole repository!

I am processing a new digital edition of Herodotus from a legacy XML text. I have done a lot of pre-processing, and have gotten the (now invalid) XML file to this state: `source-data/texts/History/herodotus2.xml`

I want to get it into a CEX format like this, older, CEX version of Herodotus: `source-data/texts/History/herodotus.cex`

This will involve "flattening" the former XML hierarchy into a string-representation of the hierarchical citation structure.

I would like to script this process.

What I am looking at is this, for example: 

~~~
<div1 type="book" n="1">
<div2 type="chapter" n="1">
<div3 type="section" n="0">Ἡροδότου Ἁλικαρνησσέος ἱστορίης ἀπόδεξις ἥδε, ὡς μήτε τὰ γενόμενα ἐξ ἀνθρώπων τῷ χρόνῳ ἐξίτηλα γένηται, μήτε ἔργα μεγάλα τε καὶ θωμαστά, τὰ μὲν Ἕλλησι τὰ δὲ βαρβάροισι ἀποδεχθέντα, ἀκλεᾶ γένηται, τά τε ἄλλα καὶ δι' ἣν αἰτίην ἐπολέμησαν ἀλλήλοισι. 
<div3 type="section" n="1">Περσέων μέν νυν οἱ λόγιοι Φοίνικας αἰτίους φασὶ γενέσθαι τῆς διαφορῆς. τούτους γὰρ ἀπὸ τῆς Ἐρυθρῆς καλεομένης θαλάσσης ἀπικομένους ἐπὶ τήνδε τὴν θάλασσαν, καὶ οἰκήσαντας τοῦτον τὸν χῶρον τὸν καὶ νῦν οἰκέουσι, αὐτίκα ναυτιλίῃσι μακρῇσι ἐπιθέσθαι, ἀπαγινέοντας δὲ φορτία Αἰγύπτιά τε καὶ Ἀσσύρια τῇ τε ἄλλῃ ἐσαπικνέεσθαι καὶ δὴ καὶ ἐς Ἄργος.
<div3 type="section" n="2">τὸ δὲ Ἄργος τοῦτον τὸν χρόνον προεῖχε ἅπασι τῶν ἐν τῇ νῦν Ἑλλάδι καλεομένῃ χωρῇ. ἀπικομένους δὲ τούς Φοίνικας ἐς δὴ τὸ Ἄργος τοῦτο διατίθεσθαι τὸν φόρτον.
…
~~~

The hierarchy of citation for this text is `book.chapter.section`. 

I would like to create a CEX file, like , where each citable passage is identified by `urn:cts:greekLit:tlg0016.tlg001.FUgrc:X.Y.Z`, where `X.Y.Z` is the Book-number, chapter-number, and section-number. 

The resulting CEX file, for the example given above, would look like this:

~~~
urn:cts:greekLit:tlg0016.tlg001.FUgrc:1.1.0#Ἡροδότου Ἁλικαρνησσέος ἱστορίης ἀπόδεξις ἥδε, ὡς μήτε τὰ γενόμενα ἐξ ἀνθρώπων τῷ χρόνῳ ἐξίτηλα γένηται, μήτε ἔργα μεγάλα τε καὶ θωμαστά, τὰ μὲν Ἕλλησι τὰ δὲ βαρβάροισι ἀποδεχθέντα, ἀκλεᾶ γένηται, τά τε ἄλλα καὶ δι' ἣν αἰτίην ἐπολέμησαν ἀλλήλοισι. 
urn:cts:greekLit:tlg0016.tlg001.FUgrc:1.1.1#Περσέων μέν νυν οἱ λόγιοι Φοίνικας αἰτίους φασὶ γενέσθαι τῆς διαφορῆς. τούτους γὰρ ἀπὸ τῆς Ἐρυθρῆς καλεομένης θαλάσσης ἀπικομένους ἐπὶ τήνδε τὴν θάλασσαν, καὶ οἰκήσαντας τοῦτον τὸν χῶρον τὸν καὶ νῦν οἰκέουσι, αὐτίκα ναυτιλίῃσι μακρῇσι ἐπιθέσθαι, ἀπαγινέοντας δὲ φορτία Αἰγύπτιά τε καὶ Ἀσσύρια τῇ τε ἄλλῃ ἐσαπικνέεσθαι καὶ δὴ καὶ ἐς Ἄργος.
urn:cts:greekLit:tlg0016.tlg001.FUgrc:1.1.2#τὸ δὲ Ἄργος τοῦτον τὸν χρόνον προεῖχε ἅπασι τῶν ἐν τῇ νῦν Ἑλλάδι καλεομένῃ χωρῇ. ἀπικομένους δὲ τούς Φοίνικας ἐς δὴ τὸ Ἄργος τοῦτο διατίθεσθαι τὸν φόρτον.
~~~

I am very familiar with working on the OSX/Unix command-line. I have a fully installed and updated set of XCode command-line-tools, and also a number of utilities from Homebrew.

Can you help me write a script to "flatten" this formerly XML text into a citable CEX file? 