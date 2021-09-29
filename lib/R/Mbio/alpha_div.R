#### Docs TODO
#### Compute alpha diversity
alphaDiv <- function(otu, method = c('shannon','simpson','evenness'), verbose = c(TRUE, FALSE)) {

    # Initialize and check inputs
    method <- plot.data::matchArg(method)
    verbose <- plot.data::matchArg(verbose)

    computeMessage <- ''
    plot.data::logWithTime(paste("Received OTU table with", NROW(otu), "samples and", (NCOL(otu)-1), "taxa."), verbose)
    

    # Compute alpha diversity
    if (identical(method, 'shannon') | identical(method, 'simpson')){
      alphaDivDT <- try(vegan::diversity(otu[, -c('SampleID')], method))
    } else if (identical(method, 'evenness')) {
      alphaDivDT <- try(vegan::diversity(otu[, -c('SampleID')], 'shannon') / log(vegan::specnumber(otu)))
    }

    if (is.error(alphaDivDT)) {
      computeMessage <- paste('Error: alpha diversity', method, 'failed')
      # Also handle dt, results? Or just stop?
    } else {
      computeMessage <- paste('Computed', method, 'alpha diversity.')
    }

    # Collect results
    dt <- data.table('SampleID'= otu[['SampleID']],
                      'alphaDiv' = alphaDivDT)
    data.table::setnames(dt, 'alphaDiv', method)

    results <- list(
      'dt' = dt,
      'computedVariables'= names(dt[, -c('SampleID')]),
      # 'computedVariableLabels'= c('Shannon', 'Simpson', 'Pielou\'s evenness'), # add back later
      'computedAxisLabel' = jsonlite::unbox('Alpha Diversity'),
      'defaultRange' = c(0, 1),
      'computeDetails' = jsonlite::unbox(computeMessage)
    )

    plot.data::logWithTime(paste('Alpha diversity calculations completed with parameters method=', method, ', verbose =', verbose), verbose)
    return(results)
}


#### Docs TODO
#### Wrap calculations and assembly into something helpful to send to other services
alphaDivApp <- function(otu, verbose = c(TRUE, FALSE)) {

    verbose <- plot.data::matchArg(verbose)

    methods <- c('shannon','simpson','evenness')

    appResults <- lapply(methods, alphaDiv, otu=otu, verbose=verbose)

    ## Ignoring anything past here for now...
    
    # placeholder
    # writeDT(outDT)
    # writeMetadata(outJSON)
    # get file names and return something helpful

    # For now
    return(appResults)
}