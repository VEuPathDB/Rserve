#### Docs TODO
#### Rank abundance data
rankedAbundance <- function(otu, verbose = c(TRUE, FALSE)) {

  # Initialize and check inputs
  verbose <- plot.data::matchArg(verbose)

  computeMessage <- ''
  plot.data::logWithTime(paste("Received OTU table with", NROW(otu), "samples and", (NCOL(otu)-1), "taxa."), verbose)

  # Reshape back to sample, taxonomicLevel, abundance
  formattedDT <- data.table::melt(otu, measure.vars=colnames(otu)[-1], variable.factor=F, variable.name=taxonomicLevel, value.name="Abundance")

  # Rank by method
  rankingMethods <- c('median','max','q3','var')
  rankedTaxaList <- lapply(rankingMethods, topNTaxa, df=formattedDT, cutoff=10, taxonomicLevel = taxonomicLevel)

  # Admittedly terrible. Functions but needs clenaing up. Struggled to find a nice data.table solution
  dtList <- lapply(seq_along(rankedTaxaList), function(x) {cols <- c("SampleID", rankedTaxaList[[x]][[taxonomicLevel]]); otui <- otu[, ..cols];
                                              data.table::setnames(otui, colnames(otui)[-1], paste0(colnames(otui)[-1], "_", rankingMethods[x]))
                                              return(otui)})

  plot.data::logWithTime("Finished ranking taxa", verbose)

  # Merge into one large dt
  dt <- Reduce(function(...) merge(..., all = TRUE, by='SampleID'), dtList)

  # Write results
  results <- list(
    'dt' = dt,
    'computeDetails' = computeMessage,
    'rankedTaxaList' = rankedTaxaList
  )

  return (results)
}

#### Docs TODO
#### Wrap calculations and assembly into something helpful to send to other services
rankedAbundanceApp <- function(otu, verbose=c(TRUE, FALSE)) {

  verbose <- plot.data::matchArg(verbose)

  rankedAbundanceResults <- rankedAbundance(otu, verbose)

  outDT <- rankedAbundanceResults$dt
  
  outJSON <- list(
    'computedVariable'= names(outDT[, -c('SampleID')]),
    'computedVariableLabels'= unname(unlist(rankedAbundanceResults$rankedTaxaList)),
    'yAxisLabel' = jsonlite::unbox('Relative Abundance'),
    'defaultRange' = c(0, 1),
    'computeDetails' = jsonlite::unbox(computeMessage)
  )

  # placeholder
  # writeDT(outDT)
  # writeMetadata(outJSON)
  # get file names and return something helpful

  # For now
  return(outJSON)

}