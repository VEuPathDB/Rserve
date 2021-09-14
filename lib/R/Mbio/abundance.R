#   ranking_method <- 'Median'
#   taxonomicLevel <- 'Class'
#   computeMessage <- ''

#   # This part seems redundant, but it's to get around using tidyr::complete (see shiny's otu_table.R line 18)
#   formattedDT <- formatTaxaDT(df)
#   otu <- makeOTU(formattedDT, taxonomicLevel)

#   # Reshape back to sample, taxonomicLevel, abundance
#   formattedDT <- data.table::melt(otu, measure.vars=colnames(otu)[-1], variable.factor=F, variable.name=taxonomicLevel, value.name="Abundance")

#   # Rank by method
#   rankingMethods <- c('median','max','q3','var')
#   rankedTaxaList <- lapply(rankingMethods, rankTaxa, df=formattedDT, cutoff=10, taxonomicLevel = taxonomicLevel)

#   # Admittedly terrible. Functions but needs clenaing up. Struggled to find a nice data.table solution
#   dtList <- lapply(seq_along(rankedTaxaList), function(x) {cols <- c("SampleID", rankedTaxaList[[x]][[taxonomicLevel]]); otui <- otu[, ..cols];
#                                               data.table::setnames(otui, colnames(otui)[-1], paste0(colnames(otui)[-1], "_", rankingMethods[x]))
#                                               return(otui)})

#   # Merge into one large dt
#   dt <- Reduce(function(...) merge(..., all = TRUE, by='SampleID'), dtList)


#   # Write dt
#   # writeDT(dt, "abundance")

#   # Write json metadata
#   jsonList <- list(
#     'computedVariable'= names(dt[, -c('SampleID')]),
#     'computedVariableLabels'= unname(unlist(rankedTaxaList)),
#     'yAxisLabel' = 'Relative Abundance',
#     'defaultRange' = c(0, 1),
#     'computeDetails' = computeMessage,
#     'xAxisLabel' = taxonomicLevel,
#     'plotTitle' = "Top taxa with computed value > 0"
#   )
#   # It would be helpful to revisit the title. Does it have to have the complicated logic? Can we be more clever? 
#   # Logic in the front end could just be about if there are fewer than 10 returned and the ranking method selected?
#   # So then for median, the two title options would be "Top 10 taxa ranked by median" (n>=10) and "Top taxa ranked by median (taxa with median=0 not shown)" (n<10)

#   # writeMetadata(jsonList, 'abundance')