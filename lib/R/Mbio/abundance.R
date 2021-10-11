#### Docs TODO
#### Rank abundance data
rankedAbundance <- function(otu, method = c('median','max','q3','var'), verbose = c(TRUE, FALSE), cutoff=10) {

  # Initialize and check inputs
  method <- plot.data::matchArg(method)
  verbose <- plot.data::matchArg(verbose)

  computeMessage <- ''
  plot.data::logWithTime(paste("Received OTU table with", NROW(otu), "samples and", (NCOL(otu)-1), "taxa."), verbose)

  # Reshape back to sample, taxonomicLevel, abundance
  formattedDT <- data.table::melt(otu, measure.vars=colnames(otu)[-1], variable.factor=F, variable.name='TaxonomicLevel', value.name="Abundance")

  rankedTaxa <- rankTaxa(formattedDT, method)

  # Extract top N taxa
  topN <- rankedTaxa[Abundance > 0, TaxonomicLevel]
  wasCutoff <- FALSE
  if (NROW(topN) > cutoff) {
    topN <- topN[1:cutoff]
    wasCutoff <- TRUE
  }

  keepCols <- c("SampleID", topN)

  plot.data::logWithTime("Finished ranking taxa", verbose)

  # Write results
  results <- list(
    # 'dt' = otu[, ..keepCols], #### Not necessary for us because we run the app.
    'computeDetails' = computeMessage,
    'computedVariables' = topN,
    'computedVariableLabels' = topN,
    'computedAxisLabel' = 'Relative Abundance',
    'defaultRange' = c(0,1),
    'computeName' = method,
    'wasCutoff' = wasCutoff
  )

  return (results)
}

#### Docs TODO
#### Wrap calculations and assembly into something helpful to send to other services
rankedAbundanceApp <- function(otu, verbose=c(TRUE, FALSE)) {

  verbose <- plot.data::matchArg(verbose)

  rankingMethods <- c('median','max','q3','var')
  computeResults <- lapply(rankingMethods, rankedAbundance, otu=otu, verbose=verbose)

  # Return one dt for all methods
  keepTaxa <- unique(unlist(lapply(computeResults, function(x) return(x$computedVariables))))
  dt <- otu[, ..keepTaxa]

  appResults <- list("data" = dt,
                      "stats" = NULL,
                      "metadata" = computeResults
  )
  # mergedDT <- Reduce(function(...) merge(..., all = TRUE, by='SampleID', no.dups=F), dtList)

  ## Ignoring anything past here for now...

  # placeholder
  # writeAllThatJSON()
  # get file names and return something helpful

  # For now
  return(appResults)

}
# It would be helpful to revisit the title. Does it have to have the complicated logic? Can we be more clever? 
# Logic in the front end could just be about if there are fewer than 10 returned and the ranking method selected?
# So then for median, the two title options would be "Top 10 taxa ranked by median" (n>=10) and "Top taxa ranked by median (taxa with median=0 not shown)" (n<10)
