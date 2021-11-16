library(data.table)
library(Rcpp)
## NOTE: attach our in house packages last
library(veupathUtils)
library(plot.data)
library(microbiomeComputations)

files.sources <- list.files('opt/rserve/lib/R/', full.names=TRUE, recursive=TRUE)
message('\n', Sys.time(), ' Preloading functions from the following files: ', files.sources)
invisible(sapply(files.sources, source))

