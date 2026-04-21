You are helping me with a project to generate thoroughly annotated online texts in Ancient Greek for readers. The project repository is up-to-date at: <https://github.com/Eumaeus/Dramaturg.jl/tree/main>.

In the directory `ai_queries` are the queries that got us to the present state of the project.

Since your last round of help, I have moved things around in the repository a little. I added a directory `source-data`, and the `config.toml` now points to `frogs-speaker-speech.cex` as the `cex_path`.

I have also added a file `source-data/editorial_dict_elision.tsv`. This is the first of what will be a set of files that allow editorial intervention in otherwise automated processes.

This file has a header-line, followed by rows of two columns. The first is one of the elided forms identified in the text by the code; this is `surface_form`. The second column is `expanded_form`, the unelided version, supplied by a human editor. This dictionary will be helpful for subsequent morphological parsing and helpful displays for the user.

The list in `editorial_dict_elision.tsv` is very incomplete. I expect one of my students will work through all the elided forms (316 of them) and add them to the dictionary over the next few weeks.

In the meantime, I would like to draw on the data in `source-data/editorial_dict_elision.tsv` as we generate the index and histogram of elided forms. Currently, in the output files, the fields for `expanded_form` are empty. 

Where there is an entry in `source-data/editorial_dict_elision.tsv` corresponding to the elided form, I would like the script to supply the expanded form in the correct field.

And while we are at it, this might be a good time to generate a word-histogram of all words in the play, along the lines of `data/indexes/frogs-speech-speaker_elided_histogram.tsv`. This would be a great resource for students starting to read the play, before we even finish this deluxe-reading environment.

For such a file, for elided forms we would want to use the expanded form where we have it in the dictionary. Since we have not completed the dictionary of elided forms, elided forms without dictionary entries can appear in the histogram as they are, in their "surface form". 

I hope this is a clear description of what I have in mind for the next step. If not, I will try to clarify! Thanks!
