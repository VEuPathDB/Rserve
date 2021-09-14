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

  makeOTU <- function(df, taxonomicLevel) {

    # Leaving as it's own function for now, in case we want to split it out in the future. See comment about two common formats.
    df <- processTaxaDT(df)

    # Reshape to OTU (samples x taxa)
    otu <- data.table::dcast(df, as.formula(paste0("SampleID~", taxonomicLevel)), fun.aggregate = sum, value.var = 'Abundance')

    # Replace NAs with 0
    data.table::setnafill(df, fill = 0, cols = "Abundance")

    ## Some sort of name check?

    return(otu)
  }

  # First function that touches the data. Should clean, validate types, handle rel vs abs abundance, weird taxa names, etc.
  processTaxaDT <- function(df) {

    # Data checks (everything numeric, others?)

    data.table::setDT(df)

    # Clean data - rename, fill Nas with 0
    #### Maybe this part should be a separate function of cleaning data?
    data.table::setnames(df, c("Sample ID", "Relative Abundance", "Absolute Abundance", "Kingdom/SuperKingdom"), c("SampleID", "RelativeAbundance", "AbosluteAbundance", "Kingdom"), skip_absent = T)
    data.table::setnafill(df, fill = 0, cols = c("RelativeAbundance", "AbosluteAbundance"))
    
    # Replace column N/A with unknown taxonLevel -1. 
    fullTaxonomy <- names(df)[3:(which(names(df)==taxonomicLevel))]

    invisible(lapply(fullTaxonomy, function(level){
      print(level)
      if (level == fullTaxonomy[1]) {
        # If first level is NA, set to "unclassified {first level}". Ex. "unclassified Kingdom"
        df["N/A", eval(fullTaxonomy) := paste("unclassified", level), on=level]
      } else {
        # If subsequent level is NA, set to "unclassified {previous level name}". Ex. "unclassified Sphingomonas"
        levelIndex <- which(fullTaxonomy==level)
        df["N/A", eval(fullTaxonomy[levelIndex:length(fullTaxonomy)]) := paste("unclassified", df["N/A", get(fullTaxonomy[levelIndex-1]), on=level]), on=level]
      }
    }))

    # Aggregate by taxonomic level
    byCols <- c(taxonomicLevel, 'SampleID')
    df <- df[, .("Abundance" = sum(RelativeAbundance)), by = eval(byCols)]

    
    return (df)
  }

print("Done loading microbiome utils functions!")