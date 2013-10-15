## txdb.R -- transcript database, assumes being run from project root, from Makefile

makeTxDb <- function(gtf.file, chrominfo, data.source, species) {
    chrominfo.d <- read.delim(chrominfo, header=FALSE, col.names=c("chrom", "length", "is_circular"),
                              colClasses=c("character", "integer", "logical"))

    txdb <- makeTranscriptDbFromGFF(file=gtf.file, 
                                    format="gtf",
                                    exonRankAttributeName="exon_number",
                                    chrominfo=chrominfo.d,
                                    dataSource=data.source,
                                    species=species)
    return(txdb)
}


if (!interactive()) {
    args <- as.list(commandArgs(trailingOnly=TRUE))
    message(sprintf("command line args: %s", paste(unlist(args), collapse=", ")))

    library(GenomicFeatures)
    txdb <- do.call(makeTxDb, args[-length(args)])
    sqlite.db <- args[[length(args)]]
    saveDb(txdb, file=sqlite.db)
}







