# Greek Morphology Master File

## Reconstituting `Greek_Morphology.cex`

`cat Greek_Morphology_partaa Greek_Morphology_partab Greek_Morphology_partac > Greek_Morphology.cex`

## Splitting `Greek_Morphology.cex`

`split -b 50M Greek_Morphology.cex Greek_Morphology_part`

## Copying it for Use

The scripts, by default, look for `data/morphology/Greek_Morphology.cex`.

Once you've used `cat` to assemble the large file, move it into place.
