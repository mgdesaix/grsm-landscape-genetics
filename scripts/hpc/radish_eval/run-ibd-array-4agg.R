############################################################################################################
### Likelihood ratio test of radish models to null (IBD)
### March 25, 2025
### Matt DeSaix
############################################################################################################
# Load libraries
library(radish)

# Read in arguments to script
myargs <- commandArgs(trailingOnly = TRUE) # input script arguments

model_file <- as.character(myargs[1]) # radish model file name
prefix <- as.character(myargs[2]) # prefix, to be used as output name
outdir <- as.character(myargs[3]) # outdir to write to
agg <- as.character(myargs[4]) # agg factor, ex. "4agg"

# **********************************************************************
# Import model and run evaluations
# **********************************************************************

ibd_file <- "fit_mlpe_64PCs_4agg.IBD.Rds"
fit_ibd <- readRDS(ibd_file)

fit_mlpe <- readRDS(model_file)

### Save off summary of model
anova_fit_mlpe <- anova(fit_ibd, fit_mlpe)

anova_summary <- paste0(outdir, "/", prefix, ".anova.model_summary.txt")
sink(anova_summary)
print(anova_fit_mlpe)
sink()






