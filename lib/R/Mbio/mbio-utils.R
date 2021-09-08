## Microbiome-specific helpers


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

#### Add reshapeByLevel or similar that takes df, taxonomic level, and returns df
reshapeBySelectedLevel <- function(df, taxonomicLevel) {
    # Clean data - rename, fill Nas with 0
    data.table::setnames(df, c("Sample ID", "Relative Abundance", "Absolute Abundance"), c("SampleID", "RelativeAbundance", "AbosluteAbundance"))
    data.table::setnames(df, 'Kingdom/SuperKingdom', 'Kingdom')
    setnafill(df, fill = 0, cols = c("RelativeAbundance"))

    # Aggregate by taxonomic level
    byCols <- c(taxonomicLevel, 'SampleID')
    dfFiltered <- df[, .("Abundance" = sum(RelativeAbundance)), by = eval(byCols)]
    #### Replace column N/A with unknown

    return(dfFiltered)
}