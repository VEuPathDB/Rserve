library(data.table)
library(ape)
library(vegan)
library(phytools)
library(rbiom)
library(DESeq2)
library(Rcpp)
## NOTE: attach our in house packages last
library(plot.data)
library(veupathUtils)
library(microbiomeComputations)

files.sources <- list.files('opt/rserve/lib/R/', full.names=TRUE, recursive=TRUE)
message('\n', Sys.time(), 'Preloading functions from the following files: ', files.sources)
invisible(sapply(files.sources, source))

