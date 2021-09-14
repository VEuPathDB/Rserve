## Microbiome-specific helpers

print("Loading mbio utils functions...")

## Currently just placeholders and room to brainstorm
## Parse tree from file into something helpful
# parseTree <- function....


## Naming conventions?

## Make default tree when none supplied
## NOT phase 1
makeDefaultTree <- function(taxonomy_df) {
  
    #### Eventually needs to be only the actual var details
    #### Eventually needs to make the formula based on col names
    # phylo.formula <- ...
    tree <- ape::as.phylo.formula(~Kingdom/Phylum/Class/Order, tax_df)
  
    nEdges <- dim(tree$edge)[1]
    
    # Assign edge lengths to all equal 1. 
    tree$edge.length <- rep(1, nEdges)
    
    # Root tree using the midpoint
    # tree <- phytools::pbtree(n=20,scale=30)
    tree <- phytools::midpoint.root(tree)
    
    # Force the tree to be ultrametric (all tips equadistant from root)
    tree <- phytools::force.ultrametric(tree, method="extend")

    return(tree)
}


rankTaxa <- function(df, method, cutoff, taxonomicLevel) {
    
    ## Rank by method
    if (identical(method, 'median')) {
        ranked <- df[, list(Abundance=median(Abundance)), by=taxonomicLevel]
    } else if (identical(method, 'max')) {
        ranked <- df[, list(Abundance=max(Abundance)), by=taxonomicLevel]
    } else if (identical(method, 'q3')) {
        ranked <- df[, list(Abundance=quantile(Abundance, 0.75)), by=taxonomicLevel]
    } else if (identical(method, 'var')) {
        ranked <- df[, list(Abundance=var(Abundance)), by=taxonomicLevel]
    } else {
        stop("Unsupported ranking method.")
    }

    setorderv(ranked, c("Abundance", taxonomicLevel), c(-1, 1))

    # Extract top N taxa
    topN <- ranked[Abundance > 0, ..taxonomicLevel]
    if (NROW(topN) > cutoff) {
        topN <- topN[1:cutoff]
    }

    return(topN)
}

makeOTU <- function(df, taxonomicLevel) {

    # Reshape to OTU (samples x taxa)
    otu <- data.table::dcast(df, as.formula(paste0("SampleID~", taxonomicLevel)), fun.aggregate = sum, value.var = 'Abundance')


    #### Replace NAs with 0
    data.table::setnafill(df, fill = 0, cols = "Abundance")

    ## Some sort of name check?

    return(otu)
}

formatTaxaDT <- function(df) {

    data.table::setDT(df)

    # Clean data - rename, fill Nas with 0
    #### Maybe this part should be a separate function of cleaning data?
    data.table::setnames(df, c("Sample ID", "Relative Abundance", "Absolute Abundance", "Kingdom/SuperKingdom"), c("SampleID", "RelativeAbundance", "AbosluteAbundance", "Kingdom"), skip_absent = T)
    # setnafill(df, fill = 0, cols = c("RelativeAbundance"))

    #### Replace column N/A with unknown taxonLevel -1
    ## Note setnafill does not handle chars

    # Aggregate by taxonomic level
    byCols <- c(taxonomicLevel, 'SampleID')
    df <- df[, .("Abundance" = sum(RelativeAbundance)), by = eval(byCols)]

    return (df)
}

print("Done loading microbiome utils functions!")