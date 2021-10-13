library(data.table)
library(ape)
library(vegan)
library(phytools)
library(rbiom)
library(DESeq2)
library(Rcpp)
## NOTE: attach our in house packages last
library(plot.data)
files.sources <- list.files('opt/rserve/lib/R/', full.names=TRUE, recursive=TRUE)
message('\n', Sys.time(), 'Preloading functions from the following files: ', files.sources)
invisible(sapply(files.sources, source))

# Compiled functions
comp.files.sources <- list.files('opt/rserve/lib/src/', full.names=TRUE, recursive=TRUE)
message('\n', Sys.time(), 'Compiling functions from the following files: ', comp.files.sources)
invisible(sapply(comp.files.sources, Rcpp::sourceCpp))
