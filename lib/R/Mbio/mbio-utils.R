## Microbiome-specific helpers


## Currently just placeholders and room to brainstorm
## Parse tree from file into something helpful
# parseTree <- function....


## Naming conventions?

## Make default tree when none supplied
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