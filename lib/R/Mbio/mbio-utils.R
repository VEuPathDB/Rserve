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


topNTaxa <- function(df, method=c('median','max','q3','var'), cutoff=10, taxonomicLevel="Phylum") {
  
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

    data.table::setorderv(ranked, c("Abundance", taxonomicLevel), c(-1, 1))

    # Extract top N taxa
    topN <- ranked[Abundance > 0, ..taxonomicLevel]
    if (NROW(topN) > cutoff) {
      topN <- topN[1:cutoff]
    }

    return(topN)
}

  
print("Done loading microbiome utils functions!")