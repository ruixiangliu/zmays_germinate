# programs
GZCAT := $(shell (command -v gzcat || command -v zcat) 2>/dev/null)

# output directories
RESOURCES=resources
SEQS=$(RESOURCES)/seqs

# Refgen3 Resources and Configuration
VER=19
REFGEN3_GFF3_URL=ftp://ftp.ensemblgenomes.org/pub/release-$(VER)/plants/gff3/zea_mays/Zea_mays.AGPv3.$(VER).gff3.gz
REFGEN3_GFF3_FILE=Zea_mays.AGPv3.$(VER).gff3
REFGEN3_GTF_URL=ftp://ftp.ensemblgenomes.org/pub/release-$(VER)/plants/gtf/zea_mays/Zea_mays.AGPv3.$(VER).gtf.gz
REFGEN3_GTF_FILE=Zea_mays.AGPv3.$(VER).gtf
REFGEN3_SQLITE_DB=Zea_mays.AGPv3.$(VER).sqlite
CHROMS=1 2 3 4 5 6 7 8 9 10 Mt Pt
REFGEN3_NONCHROM_SEQ_URL=ftp://ftp.ensemblgenomes.org/pub/release-19/plants/fasta/zea_mays/dna/Zea_mays.AGPv3.19.dna.nonchromosomal.fa.gz
REFGEN3_NONCHROM_SEQ=Zea_mays.AGPv3.19.dna.nonchromosomal.fa.gz
REFGEN3_CHROM_SEQS=$(foreach chrom, $(CHROMS), Zea_mays.AGPv3.$(VER).dna.chromosome.$(chrom).fa.gz)
REFGEN3_CHROM_SEQS_URLS=$(addprefix ftp://ftp.ensemblgenomes.org/pub/release-$(VER)/plants/fasta/zea_mays/dna/, $(REFGEN3_CHROM_SEQS))
REFGEN3_SEQS_URLS=$(REFGEN3_CHROM_SEQS_URLS) $(REFGEN3_NONCHROM_SEQ_URL)
REFGEN3_SEQ_FILES=$(addprefix $(SEQS)/, $(REFGEN3_CHROM_SEQS) $(REFGEN3_NONCHROM_SEQ))
REFGEN3_CHROM_INFO=Zea_mays.AGPv3.$(VER).chrom_info.txt

# primary targets
txdb: $(RESOURCES)/$(REFGEN3_SQLITE_DB)
dna: $(REFGEN3_SEQ_FILES)

$(RESOURCES)/$(REFGEN3_GFF3_FILE): | $(RESOURCES)
	@echo "Downloading RefGen3 GFF3"
	curl $(REFGEN3_GFF3_URL) | $(GZCAT) > $@

$(RESOURCES)/$(REFGEN3_GTF_FILE): | $(RESOURCES)
	@echo "Downloading RefGen3 GTF"
	curl $(REFGEN3_GTF_URL) | $(GZCAT) > $@

$(REFGEN3_SEQ_FILES): | $(SEQS)
	@echo "Downloading full RefGen3 sequences for chromosomes 1-10, Mt, Pt, and non-chromosomal"
	(cd $(SEQS) && wget $(REFGEN3_SEQS_URLS))

# Use this version if you dont't want to keep entire genome to get chromsome lengths
# $(RESOURCES)/$(REFGEN3_CHROM_INFO): | $(RESOURCES)
# 	@echo "Creating chromosome length table for RefGen3"
# 	curl $(REFGEN3_SEQS_URLS) $(REFGEN3_NONCHROM_SEQ_URL) | $(GZCAT) | bioawk -c fastx '{print $$name"\t"length($$seq)"\tNA"}' > $@

$(RESOURCES)/$(REFGEN3_CHROM_INFO): $(REFGEN3_SEQ_FILES)
	@echo "Creating chromosome length table for RefGen3"
	$(GZCAT) $^ | bioawk -c fastx '{print $$name"\t"length($$seq)"\tNA"}' > $@

$(RESOURCES)/$(REFGEN3_SQLITE_DB): $(RESOURCES)/$(REFGEN3_GTF_FILE) $(RESOURCES)/$(REFGEN3_CHROM_INFO) | $(RESOURCES)
	@echo "Creating SQLite Database of RefGen3 tracks"
	Rscript R/txdb.R $(RESOURCES)/$(REFGEN3_GTF_FILE) $(RESOURCES)/$(REFGEN3_CHROM_INFO) $(REFGEN3_GTF_URL) "Zea mays" $(RESOURCES)/$(REFGEN3_SQLITE_DB)

$(RESOURCES):
	mkdir -p $@

$(SEQS):
	mkdir -p $@
