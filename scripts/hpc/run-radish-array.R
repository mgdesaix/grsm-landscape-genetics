############################################################################################################
### Run Radish
### January 27, 2025
### Matt DeSaix
############################################################################################################
# Load libraries
library(radish)

# Read in arguments to script
myargs <- commandArgs(trailingOnly = TRUE) # input script arguments

prefix <- as.character(myargs[1]) # covariate prefix
radish_func <- as.character(myargs[2]) # input function
agg_fact <- as.integer(myargs[3]) # factor to aggregate raster cells by

# **********************************************************************
# Run Radish
# **********************************************************************

surface_file <- paste0("./data/radish/intermediary/30m_", agg_fact, "agg/conductance_surface_", agg_fact, "agg.Rds")
surface <- readRDS(surface_file)

# gen_input_file <- paste0("./data/radish/intermediary/30m_", agg_fact, "agg/gen_input_", agg_fact, "agg.Rds")
gen_input_file <- "./data/radish/genetics/pca.dist.mat.64PCs.Rds"
gen_input <- readRDS(gen_input_file)

fit_mlpe <- radish(as.formula(radish_func),
                   data = surface,
                   conductance_model = radish::loglinear_conductance,
                   measurement_model = radish::mlpe)

outname <- paste0("./out/radish/30m_", agg_fact, "agg/fit_mlpe_64PCs_", agg_fact, "agg.", prefix, ".Rds")
saveRDS(fit_mlpe, outname)

summary(fit_mlpe)





