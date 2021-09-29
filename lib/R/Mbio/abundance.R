#### Docs TODO
#### Rank abundance data
rankedAbundance <- function(otu, method = c('median','max','q3','var'), verbose = c(TRUE, FALSE)) {

    # Initialize and check inputs
    verbose <- plot.data::matchArg(verbose)

    computeMessage <- ''
    plot.data::logWithTime(paste("Received OTU table with", NROW(otu), "samples and", (NCOL(otu)-1), "taxa."), verbose)

    # Reshape back to sample, taxonomicLevel, abundance
    formattedDT <- data.table::melt(otu, measure.vars=colnames(otu)[-1], variable.factor=F, variable.name='TaxonomicLevel', value.name="Abundance")

    # Rank taxa based on specified method
    rankedTaxa <- topNTaxa(formattedDT, method, cutoff=10)
    plot.data::logWithTime("Finished ranking taxa", verbose)


    # Collect results
    keepCols <- c("SampleID", rankedTaxa$TaxonomicLevel)

    results <- list(
      'dt' = otu[, ..keepCols],
      'computeDetails' = computeMessage,
      'rankedTaxa' = rankedTaxa
    )

    return (results)
}

#### Docs TODO
#### Wrap calculations and assembly into something helpful to send to other services
rankedAbundanceApp <- function(otu, verbose=c(TRUE, FALSE)) {

    verbose <- plot.data::matchArg(verbose)

    rankingMethods <- c('median','max','q3','var')
    appResults <- lapply(rankingMethods, rankedAbundance, otu=otu, verbose=verbose)

    ## Ignoring anything past here for now...

    # placeholder
    # writeDT(outDT)
    # writeMetadata(outJSON)
    # get file names and return something helpful

    # For now
    return(appResults)

}