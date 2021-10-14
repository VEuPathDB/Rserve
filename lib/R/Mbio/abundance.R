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
    if (NROW(topN) > cutoff) {
      topN <- topN[1:cutoff]
      computeMessage <- "Applied cutoff"
    }

    keepCols <- c("SampleID", topN)

    plot.data::logWithTime("Finished ranking taxa", verbose)

    # Write results
    results <- list(
      # 'dt' = otu[, ..keepCols], #### Not necessary for us because we run the app.
      'computeDetails' = jsonlite::unbox(computeMessage),
      'computedVariables' = topN,
      'computedVariableLabels' = topN,
      'computedAxisLabel' = jsonlite::unbox('Relative Abundance'),
      'defaultRange' = c(0,1),
      'computeName' = jsonlite::unbox(method)
    )

    return(results)
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

    # Write to json
    outFileName <- writeListToJson(appResults, 'Abundance')
    return(outFileName)

}