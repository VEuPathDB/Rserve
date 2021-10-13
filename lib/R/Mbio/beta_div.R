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
      otuMat <- matrix(as.numeric(unlist(otu[, -c("SampleID")])), nrow=NROW(otu))
      dist <- jsdphyloseq(t(otuMat))
      dist <- as.dist(dist)

    } else {
      stop('Unaccepted dissimilarity method. Accepted methods are bray, jaccard, and jsd.')
    }
    plot.data::logWithTime("Computed dissimilarity matrix.", verbose)

    # Ordination
    ## Need to handle how this might err
    pcoa <- PCOA(dist)
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
      'computedVariables' = names(dt[, -c('SampleID')]),
      'computeName' = method,
      'computeDetails' = computeMessage,
      'pcoaVariance' = percentVar
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

    computeResults <- betaDiv(otu, method, k, verbose)

    outDT <- computeResults$dt

    appResults <- list("data" = computeResults$dt,
                      "stats" = list(pcoaVariance = computeResults$pcoaVariance))

    computeResults$dt <- NULL
    computeResults$pcoaVariance <- NULL
    appResults$metadata <- computeResults


    # Ignoring below this line
    # placeholder
    # writeMetadata(outJSON)
    # get file names and return something helpful

    # For now
    return(appResults)

}