You are helping me with a project to generate thoroughly annotated online texts in Ancient Greek for readers. The project repository is up-to-date at: <https://github.com/Eumaeus/Dramaturg.jl/tree/main>.

As I capture the queries that are helping you help me, I think it is valuable to be explicit about some issues of machine-readable *and* human-readable Greek dramatic texts.

This project will, I hope, be a toolkit that works for any ancient Greek text that can be expressed as an ordered list of citable passages of text, serialized as a CEX file. That is what the `#!ctsdata` block shows, a list, in text-order, or citation+text.

I am starting with dramatic texts because they are particularly difficult. The question is "What is the *text* of Aristophanes' *Frogs*?"

The text of *Frogs* is traditionally cited, like all ancient Greek dramatic texts, by line-number. So, the text of lines 6-7 is

>| τί δαί; τὸ πάνυ γέλοιον εἴπω; νὴ Δία
>| θαρρῶν γε· μόνον ἐκεῖνʼ ὅπως μὴ ʼρεῖς,

But it is a play, so we need to know who is saying which words. In a printed edition, lines 6-7 would look like this, perhaps:

```
	Ξανθίας: 
		τί δαί; τὸ πάνυ γέλοιον εἴπω;
	Διόνυσος: 
		νὴ Δία
		θαρρῶν γε· μόνον ἐκεῖνʼ ὅπως μὴ ʼρεῖς,
```	

This poses problems for analysis. If we include speaker-attribution in the "text", then a word-count for "words in the text of *Frogs*" would show that "Διόνυσος" is very, very common. But of course, the words that the audience heard from the stage did not include "Διόνυσος" that many times.

At the same time, for argument and analysis, individual lines may be pulled out of context. I might talk about line 19:

> ὢ τρισκακοδαίμων ἄρʼ ὁ τράχηλος οὑτοσί,

Or the word "τρισκακοδαίμων" in line 19. But how do I know who said that word?

The CEX format is simple and straightforward. This is why Neel Smith and I invented it, as a reaction to the complexities and ambiguities of XML. CEX is a lot easier to process than, for example, deeply nested XML structures. But unlike XML, CEX does not easily allow us to include annotations or "paratext" in a digital edition. 

In general, I don't care, since I have found that generating separate indices, keyed to the text by URN, is cleaner and infinitely more scalable.

Drama is a particular challenge, because the "paratext", speaker-attribution, really is necessary for understanding the text.

The file `working-files/speech-speaker.cex` is my solution, as a base edition from which several other "exemplars" can be derived. You have already helped me make a "tokenized-exemplar".

This block of `working-files/speech-speaker.cex` (lines 23-26 in the text file) illustrates how it works and how CTS-URNs can help:

```
urn:cts:greekLit:tlg0019.tlg009.fu.sp:5.1.speaker#Ξανθίας
urn:cts:greekLit:tlg0019.tlg009.fu.sp:5.1.text#μηδʼ ἕτερον ἀστεῖόν τι;
urn:cts:greekLit:tlg0019.tlg009.fu.sp:5.2.speaker#Διόνυσος
urn:cts:greekLit:tlg0019.tlg009.fu.sp:5.2.text#πλήν γʼ “ὡς θλίβομαι.” 
```

The principle of the CTS-URN is that "you can always drop the right-hand element of the citation and have a valid identifier." In the case of these four entries in the CEX, we could drop two fields from the right of the CTS-URN and have:

```
urn:cts:greekLit:tlg0019.tlg009.fu.sp:5
urn:cts:greekLit:tlg0019.tlg009.fu.sp:5
urn:cts:greekLit:tlg0019.tlg009.fu.sp:5
urn:cts:greekLit:tlg0019.tlg009.fu.sp:5
```

So we know that all four lines constitute the traditionally cited line 5 of the play:

> **Ξανθίας:** μηδʼ ἕτερον ἀστεῖόν τι; **Διόνυσος:** πλήν γʼ “ὡς θλίβομαι.

If we drop only one right-hand field from the citation, we get:

```
urn:cts:greekLit:tlg0019.tlg009.fu.sp:5.1
urn:cts:greekLit:tlg0019.tlg009.fu.sp:5.1
urn:cts:greekLit:tlg0019.tlg009.fu.sp:5.2
urn:cts:greekLit:tlg0019.tlg009.fu.sp:5.2
```

That is "line 5, speech 1" and "line 5, speech 2."

In each of "speech 1" and "speech 2" we have a "speaker" node and a "text" node, each with text-content.

With `working-files/speech-speaker.cex` as a base, we can generate other editions:

1. An edition that omits speaker-attribution altogether, and consists only of words uttered on the stage. This would serve well for word-counts, histograms, etc.
2. An edition that associates each word-token explicitly with the character who speaks it. This would be ideal for discourse-analysis.
3. An edition to be the basis for a presentation formatted for human readers, that includes speaker-attribution, but only when the speaker changes.

Further, since each of these editions will be cited by URN, and all will be based on `urn:cts:greekLit:tlg0019.tlg009.fu.sp:`, and all will have, as the left-most element of the citation-hierarchy, the traditional citation-by-line, any indexing to one edition should be easily translated into an index to any other.

The TEI-XML philosophy is to try to encode all complexity into one document, and use XPATH or regex to find and extract whatever one wants. Our philosophy is to keep things simple, and to assume that it is always easier to aggregate than to disaggregate.

Your help today has given me every confidence that this will work. I will be back shortly with concrete next steps.