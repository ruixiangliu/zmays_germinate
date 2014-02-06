# *Zea mays* Germinate -- Makefile to Generate Some Maize Genomics Resources

`zmays_germinate` is reproducible genomic resource generation for *Zea mays*. Information comes from Ensembl (but maybe later, from MaizeGDB). 

## Versions

There are three major releases of the maize genome: AGPv1 (from [Schnable et
al., 2009](http://www.sciencemag.org/content/326/5956/1112)), AGPv2, and AGPv3.
Ensembl supports AGPv2 and AGPv3, but their release cycle and version numbers
are based on their Ensembl genome scheme.

The `Makefile` contains a variable `AGP_VER` that can be changed to either: `AGPv2.17` (the last Ensembl release of AGPv2) or `AGPv3.20` (the most recent release of AGPv3). Note that this only changes what the makefile gathers -- transcript databases created by `R/txdb.R` will use Ensembl's mart databases, but will explicitly version everything created under the directory `data`.

## Data

All data is downloaded to `data/`.

### Sequences

A `Makefile` downloads all non-masked sequence from chromosomes 1-10, and Pt
and Mt. Currently, the "unknown" chromosome is ignored (but this and other
changes can be easily made to the `Makefile`). Sequences are unzipped and combined
into a file with the suffix `_combined.fa` in the particular version directory.

### Annotation

Ensembl's AGPv2 version only contains a GTF file, but a GTF file and GFF3 file are available for AGPv3. 

### Resources

There are some derived resources created. For example
