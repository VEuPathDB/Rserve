#### Docs TODO
#### Compute alpha diversity
alphaDiv <- function(otu, verbose = c(TRUE, FALSE)) {

  # Initialize and check inputs
  verbose <- plot.data::matchArg(verbose)

  computeMessage <- ''
  plot.data::logWithTime(paste("Received OTU table with", NROW(otu), "samples and", (NCOL(otu)-1), "taxa."), verbose)


  # Compute all alpha diversity metrics
  shannon <- try(vegan::diversity(otu[, -c('SampleID')], 'shannon'))
  simpson <- try(vegan::diversity(otu[, -c('SampleID')], 'simpson'))
  evenness <- try(shannon / log(vegan::specnumber(otu)))

  if (any(is.error(c(shannon, simpson, evenness)))) {
    computeMessage <- "Error, alpha diversity calculations failed"
    # Also handle dt, results?
  } else {
    computeMessage <- "Computed shannon, simpson, evenness alpha diversity measures."
  }

  # Assemble data table
  dt <- data.table('SampleID'= otu[['SampleID']],
                  'shannon' = shannon,
                  'simpson' = simpson,
                  'evennness' = evenness)

  results <- list(
    'dt' = dt,
    'computeDetails' = computeMessage
  )

  plot.data::logWithTime(paste('Alpha diversity calculations completed with parameters verbose =', verbose), verbose)
  return(results)
}


#### Docs TODO
#### Wrap calculations and assembly into something helpful to send to other services
alphaDivApp <- function(otu, verbose = c(TRUE, FALSE)) {

  verbose <- plot.data::matchArg(verbose)

  alphaDivResults <- alphaDiv(otu, verbose)

  outDT <- alphaDivResults$dt
  outJSON <- list(
    'computedVariable'= names(dt[, -c('SampleID')]),
    'computedVariableLabels'= c('Shannon', 'Simpson', 'Pielou\'s evenness'),
    'yAxisLabel' = jsonlite::unbox('Alpha Diversity'),
    'defaultRange' = c(0, 1),
    'computeDetails' = jsonlite::unbox(alphaDivResults$computeDetails)
  )
  
  # placeholder
  # writeDT(outDT)
  # writeMetadata(outJSON)
  # get file names and return something helpful

  # For now
  return(outJSON)
}