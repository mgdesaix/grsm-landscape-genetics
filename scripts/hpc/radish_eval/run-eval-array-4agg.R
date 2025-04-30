############################################################################################################
### Evaluate radish models
### February 11, 2025
### Matt DeSaix
############################################################################################################
# Load libraries
library(radish)
library(tidyverse)
library(raster)

# Read in arguments to script
myargs <- commandArgs(trailingOnly = TRUE) # input script arguments

model_file <- as.character(myargs[1]) # radish model file name
prefix <- as.character(myargs[2]) # prefix, to be used as output name
outdir <- as.character(myargs[3]) # outdir to write to
agg <- as.character(myargs[4]) # agg factor, ex. "4agg"

# **********************************************************************
# Import model and run evaluations
# **********************************************************************

gen_input_file <- "/lustrefs/nwrc/projects/DeSaix/GSMNP/data/radish/genetics/pca.dist.mat.64PCs.Rds"
gen_input <- readRDS(gen_input_file)

surface_file <- paste0("/lustrefs/nwrc/projects/DeSaix/GSMNP/data/radish/intermediary/30m_", agg, "/conductance_surface_", agg, ".Rds")
surface <- readRDS(surface_file)

fit_mlpe <- readRDS(model_file)

### Save off summary of model
summary_fit_mlpe <- summary(fit_mlpe)

out_summary <- paste0(outdir, "/", prefix, ".model_summary.txt")
sink(out_summary)
print(summary_fit_mlpe)
sink()

### Save off plot of resistance vs genetic distance fit
fitted.df <- tibble("resistance_distance" = as.vector(fitted(fit_mlpe, "distance")),
                    "genetic_distance" = as.vector(gen_input))
out_fitted_df <- paste0(outdir, "/", prefix, ".fitted_df.txt")
write_delim(fitted.df, out_fitted_df)

p.fitted <- fitted.df %>%
  ggplot() +
  geom_point(aes(x = resistance_distance,
                 y = genetic_distance)) +
  xlab("Genetic distance (64 PCs)") +
  ylab("Optimized resistance distance") +
  theme_bw()

out_plot <- paste0(outdir, "/", prefix, ".fitted_plot.png")
ggsave(plot = p.fitted, filename = out_plot,
       width = 6, height = 4)

### Save off conductance raster
fitted_conductance <- conductance(surface, fit_mlpe, quantile = 0.95)
out_raster <- paste0(outdir, "/", prefix, ".conductance_raster.tif")
raster::writeRaster(fitted_conductance[["est"]], 
                    out_raster,
                    format = "GTiff")





