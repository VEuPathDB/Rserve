#
# Runs RServe but with locally mounted plot.data (PD)
#

# Helpful for development
library(devtools)

warning("hello from runLocalPD.R")

# Load local library from source (mounted inside the container from host)
devtools::install(pkg = './plot.data', quick = TRUE, dependencies = FALSE)
		      
Rserve::Rserve(debug = TRUE, args="--vanilla")
