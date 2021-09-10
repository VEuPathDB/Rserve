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

## From the input taxon abundance data frame, create an otu (samples x taxa) table.
makeOTU <- function(df, taxonomicLevel) {

    # Clean data - rename, fill Nas with 0
    #### Maybe this part should be a separate function?
    data.table::setnames(df, c("Sample ID", "Relative Abundance", "Absolute Abundance", "Kingdom/SuperKingdom"), c("SampleID", "RelativeAbundance", "AbosluteAbundance", "Kingdom"), skip_absent = T)
    setnafill(df, fill = 0, cols = c("RelativeAbundance"))

    # Aggregate by taxonomic level
    byCols <- c(taxonomicLevel, 'SampleID')
    df <- df[, .("Abundance" = sum(RelativeAbundance)), by = eval(byCols)]
    
    #### Replace column N/A with unknown

    # Reshape to OTU (samples x taxa)
    otu <- data.table::dcast(df, as.formula(paste0("SampleID~", taxonomicLevel)), fun.aggregate = sum, value.var = 'Abundance')

    # Replace NAs with 0
    # setnafill(df, fill = 0, cols = -c("SampleID"))


    return(df)
}