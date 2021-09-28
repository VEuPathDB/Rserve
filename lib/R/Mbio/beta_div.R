#### Docs TODO
#### Beta diversity calculations 
betaDiv <- function(otu,
                    method = c('bray','jaccard','jsd'),
                    k = 2,
                    verbose = c(TRUE, FALSE)) {

  # Initialize and check inputs
  method <- plot.data::matchArg(method)
  verbose <- plot.data::matchArg(verbose)

  computeMessage <- ''
  plot.data::logWithTime(paste("Received OTU table with", NROW(otu), "samples and", (NCOL(otu)-1), "taxa."), verbose)

  # Compute beta diversity using given dissimilarity method
  if (identical(method, 'bray') | identical(method, 'jaccard')) {

    dist <- vegan::vegdist(otu[, -c('SampleID')], method=method, binary=TRUE)

  } else if (identical(method, 'jsd')) {

    # TO DO

  } else {
    stop('Unaccepted dissimilarity method. Accepted methods are bray, jaccard, and jsd.')
  }
  plot.data::logWithTime("Computed dissimilarity matrix.", verbose)

  # Ordination
  ## Need to handle how this might err
  pcoa <- ape::pcoa(dist)
  dt <- data.table::as.data.table(pcoa$vectors)
  computeMessage <- paste("PCoA returned results for", NCOL(dt), "dimensions.")

  dt$SampleID <- otu[['SampleID']]
  data.table::setcolorder(dt, c('SampleID'))
  plot.data::logWithTime("Finished ordination step.", verbose)

  # Extract percent variance
  eigenvecs <- pcoa$values$Relative_eig
  percentVar <- round(100*(eigenvecs / sum(eigenvecs)), 1)

  # Keep dims 1:k
  # We should keep the same number of percentVar values as cols in the data table. However, i think we're letting the user download lots of columns? So perhaps we shouldn't have k at all? A plot can use however many it needs.
  percentVar <- percentVar[1:k]

  # Perhaps this would be more clear if pcoaVar and computeDetails were attributes of dt? Worth making a class?
  results <- list(
    'dt' = dt,
    'pcoaVariance' = percentVar,
    'computeDetails' = computeMessage
  )

  plot.data::logWithTime(paste('Beta diversity calculations completed with parameters method =', method, ', k =', k, ', verbose =', verbose), verbose)
  return(results)
}

#### Docs TODO
#### Wrap calculations and assembly into something helpful to send to other services
betaDivApp <- function(otu,
                    method = c('bray','jaccard','jsd'),
                    k = 2,
                    verbose = c(TRUE, FALSE)) {

  method <- plot.data::matchArg(method)
  verbose <- plot.data::matchArg(verbose)

  betaDivResults <- betaDiv(otu, method, k, verbose)

  outDT <- betaDivResults$dt
  outJSON <- list(
    'computedVariable'= colnames(outDT),
    'computedVariableLabels'= colnames(outDT), 
    'xAxisLabel' = jsonlite::unbox(paste0(colnames(outDT)[2], ", ", percentVar[1], "%")),  # col 1 is sample id
    'yAxisLabel' = jsonlite::unbox(paste0(colnames(outDT)[3], ", ", percentVar[2], "%")), 
    'defaultRange' = c(0, 1),
    'pcoaVariance' = betaDivResults$pcoaVariance,
    'computeDetails' = jsonlite::unbox(betaDivResults$computeDetails)
  )

  # placeholder
  # writeDT(outDT)
  # writeMetadata(outJSON)
  # get file names and return something helpful

  # For now
  return(outJSON)

}