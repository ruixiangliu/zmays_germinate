## Makefile for building genomic resources for maize

## Ensembl information
# Note that the latest Ensembl build that corresponds to AGPv2 is 17
AGP_VER=AGPv3.20
AGP_RVER=$(shell echo $(AGP_VER) | cut -f2 -d.)

## Output locations
DDIR=data
AGP_DIR=$(DDIR)/$(AGP_VER)
#AGP_DIR=$(subst ., _, $(AGP_VER))

$(AGP_DIR):
		mkdir -p $(DDIR)/$(AGP_VER)/{seqs,annot,resources}

## Base URLs to resources
AGP_SEQ_URL=ftp://ftp.ensemblgenomes.org/pub/release-$(AGP_RVER)/plants/fasta/zea_mays/dna/
# Note: GFF3 is for AGPv3 only
AGP_GFF3_URL=ftp://ftp.ensemblgenomes.org/pub/plants/release-$(AGP_RVER)/gff3/zea_mays/Zea_mays.$(AGP_VER).gff3.gz
AGP_GTF_URL=ftp://ftp.ensemblgenomes.org/pub/plants/release-$(AGP_RVER)/gtf/zea_mays/Zea_mays.$(AGP_VER).gtf.gz

## Sequences
CHROMS=1 2 3 4 5 6 7 8 9 10 Mt Pt
SEQ_FILENAMES=$(foreach chrom, $(CHROMS), Zea_mays.$(AGP_VER).dna.chromosome.$(chrom).fa.gz)
SEQ_URLS=$(addprefix $(AGP_SEQ_URL), $(SEQ_FILENAMES))
LOCAL_SEQ_FILES=$(addprefix $(AGP_DIR)/seqs/, $(SEQ_FILENAMES))

## Files
AGP_GTF=$(AGP_DIR)/annot/Zea_mays.$(AGP_VER).gtf
AGP_GFF3=$(AGP_DIR)/annot/Zea_mays.$(AGP_VER).gff3
gtf: $(AGP_GTF)
gff: $(AGP_GFF3)
COMBINED_FASTA=$(AGP_DIR)/seqs/$(AGP_VER)_combined.fa
SEQ_LENGTHS=$(AGP_DIR)/resources/$(AGP_VER)_lengths.txt
all: $(LOCAL_SEQ_FILES) gtf

$(COMBINED_FASTA) $(LOCAL_SEQ_FILES): | $(AGP_DIR)
	@echo "Downloading full sequences for chromosomes 1-10, Mt, Pt"
	(cd $(AGP_DIR)/seqs && wget $(SEQ_URLS))
	(cd $(AGP_DIR)/seqs && gzcat $(LOCAL_SEQ_FILES) > $(COMBINED_FASTA) )

$(AGP_GFF3): | $(AGP_DIR)
	@echo "Downloading GFF3"
	curl $(AGP_GFF3_URL) | gzcat > $@

$(AGP_GTF): | $(AGP_DIR)
	@echo "Downloading GTF"
	curl $(AGP_GTF_URL) | gzcat > $@

$(SEQ_LENGTHS): $(COMBINED_FASTA) | $(AGP_DIR)
	@echo "creating table of sequence lengths"
	bioawk -c fastx '{print $$name"\t"length($$seq)"\tNA"}' $^ > $@

