#   ## Inputs
#   taxonomicLevel <- 'Class'
#   verbose <- TRUE

#   computeMessage <- ''
# plot.data::logWithTime(paste("Read OTU table with", NROW(otu), "samples and", (NCOL(otu)-1), "taxa."), verbose)
  

#   ## Actual alpha div calculations
#   # Assume taxa are cols always
#   shannon <- try(vegan::diversity(otu[, -c('SampleID')], 'shannon'))
#   simpson <- try(vegan::diversity(otu[, -c('SampleID')], 'simpson'))
#   evenness <- try(shannon / log(vegan::specnumber(otu)))

#   if (any(is.error(c(shannon, simpson, evenness)))) {
#     computeMessage <- "Error, alpha diversity calculations failed"
#     # Also handle dt, outJSON?
#   } else {
#     computeMessage <- "Computed shannon, simpson, evenness alpha diversity measures."
#     plot.data::logWithTime("Finished computing alpha diversity measures.", verbose)
#   }

#   # Assemble data table
#   dt <- data.table('SampleID'= otu[['SampleID']],
#                    'shannon' = shannon,
#                    'simpson' = simpson,
#                    'evennness' = evenness)


#   # writeDT(dt, 'alphadiv', verbose)

#   # Write json metadata
#   jsonList <- list(
#     'computedVariable'= names(dt[, -c('SampleID')]),
#     'computedVariableLabels'= c('Shannon', 'Simpson', 'Pielou\'s evenness'),
#     'yAxisLabel' = jsonlite::unbox('Alpha Diversity'),
#     'defaultRange' = c(0, 1),
#     'computeDetails' = jsonlite::unbox(computeMessage)
#   )

#   # writeMetadata(jsonList, 'alphadiv', verbose)

#   print(head(dt))
#   print(jsonList)

#   plot.data::logWithTime("Completed alpha diversity app.", verbose)