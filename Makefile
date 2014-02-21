## Makefile for building genomic resources for maize

## Ensembl information
# Note that the latest Ensembl build that corresponds to AGPv2 is 17
AGP_VER=AGPv2.17
#AGP_VER=AGPv3.20
AGP_RVER=$(shell echo $(AGP_VER) | cut -f2 -d.)

## Portability
ZCAT=gzcat

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
ifeq ($(AGP_VER),AGPv2.17) # resolve naming inconsistency
	CHROMS=1 2 3 4 5 6 7 8 9 10 mitochondrion chloroplast
else
	CHROMS=1 2 3 4 5 6 7 8 9 10 Mt Pt
endif
SEQ_FILENAMES=$(foreach chrom, $(CHROMS), Zea_mays.$(AGP_VER).dna.chromosome.$(chrom).fa.gz)
SEQ_URLS=$(addprefix $(AGP_SEQ_URL), $(SEQ_FILENAMES))
LOCAL_SEQ_FILES=$(addprefix $(AGP_DIR)/seqs/, $(SEQ_FILENAMES))

.PHONY: gtf gff all clean clean-annot clean-resources
## Files
AGP_GTF=$(AGP_DIR)/annot/Zea_mays.$(AGP_VER).gtf
AGP_GFF3=$(AGP_DIR)/annot/Zea_mays.$(AGP_VER).gff3
gtf: $(AGP_GTF)
gff: $(AGP_GFF3)
COMBINED_FASTA=$(AGP_DIR)/seqs/$(AGP_VER)_combined.fa
SEQ_LENGTHS=$(AGP_DIR)/resources/$(AGP_VER)_lengths.txt

all: $(COMBINED_FASTA) gtf $(SEQ_LENGTHS)

$(LOCAL_SEQ_FILES): | $(AGP_DIR)
	@echo "Downloading full sequences for chromosomes 1-10, Mt, Pt"
	(cd $(AGP_DIR)/seqs && wget $(SEQ_URLS))
	touch $@

$(COMBINED_FASTA): $(LOCAL_SEQ_FILES) | $(AGP_DIR)
	($(ZCAT) $(LOCAL_SEQ_FILES) > $(COMBINED_FASTA))

$(AGP_GFF3): | $(AGP_DIR)
	@echo "Downloading GFF3"
	wget -O - $(AGP_GFF3_URL) | $(ZCAT) > $@
	touch $@

$(AGP_GTF): | $(AGP_DIR)
	@echo "Downloading GTF"
	wget -O - $(AGP_GTF_URL) | $(ZCAT) > $@
	touch $@

$(SEQ_LENGTHS): $(COMBINED_FASTA) | $(AGP_DIR)
	@echo "creating table of sequence lengths"
	bioawk -c fastx '{print $$name"\t"length($$seq)}' $^ > $@

clean:
	rm -rf $(AGP_DIR)

clean-annot:
	rm -f $(AGP_DIR)/annot/*

clean-resources:
	rm -f $(AGP_DIR)/resources/*
