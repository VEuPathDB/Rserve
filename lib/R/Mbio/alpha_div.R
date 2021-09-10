## Alpha div
# Assumes data read into variable called 'df'

taxonomicLevel <- 'Class'

##### Add data checks (everything numeric, others?)
# validate numeric
# validate df is data.frame
data.table::setDT(df)

#### Also need to clean data (handle unknown taxa). Maybe separate function?
otu <- makeOTU(df, taxonomicLevel)

## Actual alpha div calculations
# Assume taxa are cols always

# Compute message can hold errors or extra info about the computation (convergence time, replace NA info, etc.)
computeMessage <- ''


# Compute alpha diversity and evenness
# try(
shannon <- vegan::diversity(otu[, -c('SampleID')], 'shannon')
simpson <- vegan::diversity(otu[, -c('SampleID')], 'simpson')
evenness <- shannon / log(vegan::specnumber(otu))
# )
# if error, computeMessage <- error else, computeMessage <- 'computed shannon, simpson, evenness'

# Assemble data table
dt <- data.table('SampleID'= otu[['SampleID']],
                'shannon' = shannon,
                'simpson' = simpson,
                'evennness' = evenness)


# writeDT(dt, 'alphadiv')

# Write json metadata -- should be preconfigured above in case of error.
jsonList <- list(
'computedVariable'= names(dt[, -c('SampleID')]),
'computedVariableLabels'= c('Shannon', 'Simpson', 'Pielou\'s evenness'),
'yAxisLabel' = 'Alpha Diversity',
'defaultRange' = c(0, 1),
'computeDetails' = computeMessage
)