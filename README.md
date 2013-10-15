# *Zea mays* Germinate -- Makefile to Generate Some Maize Genomics Resources

This is a repository that downloads and makes some resources for *Zea
mays* (currently RefGen3v19) from Ensembl plants. RefGen3v20 can be
acquired too by changing `VER` in the `Makefile`.

So far, there are to primary targets:

1. `txdb`: build a SQLite database of RefGen3 transcripts from the
   GFF3, using Bioconductor's GenomicFeatures.

2. `chrs`: download unmasked RefGen3 chromosomes.


