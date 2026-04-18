
You have been helping me with several projects, including this one: <https://github.com/Eumaeus/pos-julia>. I want to begin writing a larger code library that enables the following:

1. Via a configuration file, input a Greek text from a CEX source (see <https://github.com/cite-architecture/cex>).
1. Tokenize that text into words, spaces, and puntuation.
1. Align each word with morphological data (see <https://github.com/Eumaeus/pos-julia>).
1. Also align each word-token with an entry in the *LSJ* lexicon, which I have edited into Markdown and put online here: <https://github.com/Eumaeus/cite_lsj_cex>.
1. Generate a series of HTML "Reader Pages" that include the Greek text and morphological information, to help students (and anyone else) read the text more easily.
	1. Via the configuration file, I will want control over how many lines of Greek text appear on each page.
	1. The pages should have navigation-links among them.
	1. The "boilerplate" HTML/CSS/JS should be in separate template files, identified via the Config.
1. Farther down the road, I would like to ensure that I can add:
	1. A separate "editor's view" set of HTML pages, in which an editor can, for example, look at a word that has multiple morphological parsings and select the correct one for one specific occurence of the word in one particular point in the text.
	1. This editorial data should be able to be saved as a per-text additional data input for generating the Reader Pages.
	1. Provision for adding syntactic information to the Reader Pages (see, below, for a link to a "Reader" that I made to include syntax.)
	1. Additional functions that produce additional "editions" of the original text from the CEX source, formatted and encoded for specific analytical functions.
1. The library should include provision for unit-testing functions.

My model is an earlier project that I made, using the text of Sophocles' *Oedipus Tyrannos*: <https://github.com/Eumaeus/Oedipus_2019>.

I would like to focus on Greek dramatic texts, tragedy and comedy, first, because the identification of speakers, and presentation of speaker-attributions in a reading environment, presents certain challenges. But if this library works for drama, it should work for all poetry and prose as well.

**Today** I want to start small. Can you help me set up the framework for a Julia project like this, with directories and utility files, and then do an initial commit to GitHub?



Can you help me with this first step? Thanks!


--------

This is great! As we go forward, I am calling this project "Dramaturg", as opposed to "GreekReader" as you suggested. I have made this change in all the files and the repository. 



--------

	https://github.com/neelsmith/citable-texts
	https://github.com/neelsmith/Treebanks.jl/blob/main/test/morphology.jl
