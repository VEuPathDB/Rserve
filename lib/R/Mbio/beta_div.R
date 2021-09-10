## Inputs
taxonomicLevel <- 'Class'
k <- 20  # Keep pcoa dims
method <- 'bray'


# Do argument checks
# method = c('bray', 'jaccard', 'jsd', 'unifrac', 'wunifrac')

# Data checks (everything numeric, others?)
# validate numeric
# validate df is data.frame
data.table::setDT(df)

# Create otu table (samples x taxa)
otu <- makeOTU(df, taxonomicLevel)

# Compute beta div based on input
if (identical(method, 'bray') | identical(method, 'jaccard')) {

    dist <- vegan::vegdist(otu[, -c('SampleID')], method=method, binary=TRUE)
    computeMessage <- 'Didn\'t fail.'

} else if (identical(method, 'jsd')) {

    # TO DO

} else {
    stop('wrong.')
}

# Ordination
pcoa <- ape::pcoa(dist)
dt <- data.table::as.data.table(pcoa$vectors)
dt$SampleID <- otu[['SampleID']]
data.table::setcolorder(dt, c('SampleID'))
print(head(dt))

# Do we need sample names (row names)?

# From live site. Double check
eigvec <- pcoa$values$Relative_eig
fracvar <- eigvec / sum(eigvec)
percvar <- round(100*fracvar, 1)

# writeDT(dt, 'betadiv') # Also keep only first k dimensions? Or does the user get them all?

# Keep dims 1:20?
percvar <- percvar[1:k]
# or just plug in k below. Do we want to return allllllllll columns of dt or just 20?

# Write json metadata
jsonList <- list(
    'computedVariable'= colnames(dt),
    'computedVariableLabels'= colnames(dt), # paste(colnames(dt), " ", percvar, "%")
    'xAxisLabel' = colnames(dt)[1], # paste with percvar
    'yAxisLabel' = colnames(dt)[2], # paste with percvar
    'defaultRange' = c(0, 1), # Do we need this?
    'plotTitle' = 'PCoA of Beta Diversity Distances',
    'pcoaVariance' = percvar,
    'computeDetails' = computeMessage
)

print(jsonList)
