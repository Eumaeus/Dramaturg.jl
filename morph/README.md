# Capturing Morphology using *Morpheus*

### The Data

You can pipe a list of Greek words in [Beta-Code]() to Morpheus and capture the output.

## Running

Run the legacy *morpheus* code via a [Docker container](https://www.docker.com/products/docker-desktop/).

1. Download and install [Docker](https://www.docker.com/products/docker-desktop/).
1. Open the Docker application.
1. In the Terminal, type `docker pull perseidsproject/morpheus`
1. Test the installation with `docker run -it perseidsproject/morpheus /bin/bash`
1. Type `exit` to quick the virtual machine.

You need to share a directory between your host computer, where `Dramaturg` resides, and the Docker virtual machine. By default, this will be `Dramaturg/morph`.

Start the VM, sharing that directory, with:

`docker run --platform linux/amd64 -v /ABSOLUTE/PATH/TO/YOUR/Dramaturg/morph:/morpheus/morph -it perseidsproject/morpheus /bin/bash`

## Simple Queries

Test it by typing, in the terminal showing the Virtual Machine:

`echo 'a)/nqrwpos' | MORPHLIB=stemlib bin/cruncher -S`

You can capture output from Morpheus to the shared directory `morph/output/`:

`echo 'a)/nqrwpos' | MORPHLIB=stemlib bin/cruncher -S | tee morph/output/test.txt`

That should result in a file in the Dramaturg checkout folder: `Dramaturg/morph/output/test.txt`

You can exit the VM with `exit`. Then you can quit the Docker application.

## Batch Processing Vocabulary

Make a list of words, in BetaCode, one to a line: `morph/source-data/words.txt`.

Within the VM, execute this:

`MORPHLIB=stemlib bin/cruncher -S < morph/source-data/words.txt > morph/output/analysis.txt 2> morph/output/errors.log`

The successful parsings will appear in `/morph/output/analysis.txt`.

Errors in parsing will be logged to `/morph/output/errors.log`.

## Next Steps

TBD