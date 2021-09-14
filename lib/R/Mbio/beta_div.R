#   ## Inputs
#   taxonomicLevel <- 'Class'
#   k <- 20  # Keep pcoa dims
#   method <- 'bray'
#   verbose <- TRUE

#   computeMessage <- ''
  
#   # Do argument checks
#   # method = c('bray', 'jaccard', 'jsd')

#   # Create otu table (samples x taxa)
#   otu <- makeOTU(df, taxonomicLevel)
#   plot.data::logWithTime(paste("Created OTU table with", NROW(otu), "samples and", (NCOL(otu)-1), "taxa."), verbose)

#   # Compute beta div based on input
#   if (identical(method, 'bray') | identical(method, 'jaccard')) {

#     dist <- vegan::vegdist(otu[, -c('SampleID')], method=method, binary=TRUE)

#   } else if (identical(method, 'jsd')) {

#     # TO DO

#   } else {
#     stop('Unaccepted distance method. Accepted methods are bray, jaccard, and jsd.')
#   }
#   plot.data::logWithTime("Computed distance matrix.", verbose)

#   # Ordination
#   ## Need to handle how this might err
#   pcoa <- ape::pcoa(dist)
#   dt <- data.table::as.data.table(pcoa$vectors)
#   computeMessage <- paste("PCoA returned results for", NCOL(dt), "dimensions.")
#   dt$SampleID <- otu[['SampleID']]
#   data.table::setcolorder(dt, c('SampleID'))
#   plot.data::logWithTime("Finished ordination step.", verbose)

#   # Extract percent variance
#   eigenvecs <- pcoa$values$Relative_eig
#   percentVar <- round(100*(eigenvecs / sum(eigenvecs)), 1)


#   # Keep dims 1:20?
#   percentVar <- percentVar[1:k]
#   # or just plug in k below. Do we want to return allllllllll columns of dt or just 20?
  
#   # writeDT(dt, 'betadiv', verbose) # Also keep only first k dimensions? Or does the user get them all?
#   print(head(dt))

#   # Write json metadata
#   jsonList <- list(
#     'computedVariable'= colnames(dt),
#     'computedVariableLabels'= colnames(dt), # paste(colnames(dt), " ", percvar, "%")
#     'xAxisLabel' = jsonlite::unbox(paste0(colnames(dt)[1], ", ", percentVar[1], "%")),  # paste with percvar
#     'yAxisLabel' = jsonlite::unbox(paste0(colnames(dt)[2], ", ", percentVar[2], "%")), # paste with percvar
#     'defaultRange' = c(0, 1), # Do we need this?
#     'plotTitle' = jsonlite::unbox('PCoA of Beta Diversity Distances'),
#     'pcoaVariance' = percentVar,
#     'computeDetails' = jsonlite::unbox(computeMessage)
#   )

#   print(jsonList)
#   #  writeMetadata(jsonList, 'betadiv', verbose)

#   plot.data::logWithTime("Completed beta diversity app.", verbose)