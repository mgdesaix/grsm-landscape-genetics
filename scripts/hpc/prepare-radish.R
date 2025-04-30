############################################################################################################
### Run radish
### January 27, 2025
### Matt DeSaix
############################################################################################################

# Load libraries
library(radish)
library(tidyverse)
library(raster)
library(sf)

myargs <- commandArgs(trailingOnly = TRUE) # input script arguments
agg_fact <- as.integer(myargs[1]) # factor to aggregate raster cells by

# Read in environmental data
slope.lyr <- raster("./data/radish/covariates/grsm.slope.30m.tif")
elevation.lyr <- raster("./data/radish/covariates/grsm.elevation.30m.tif")
canopy.lyr <- raster("./data/radish/covariates/grsm.canopy.30m.tif")
nlcd.lyr <- raster("./data/radish/covariates/grsm.nlcd.30m.tif")

roads.lyr <- raster("./data/radish/covariates/grsm.roads.30m.tif")
water.lyr <- raster("./data/radish/covariates/grsm.water.30m.tif")

# Categorize NLCD raster (make factors)
nlcd.cat <- ratify(nlcd.lyr)
nlcd.rat <- levels(nlcd.cat)[[1]]
full.nlcd.df <- data.frame("ID" = c(11, 12,
                                    21, 22, 23, 24,
                                    31,
                                    41, 42, 43,
                                    51, 52,
                                    71, 72, 73, 74,
                                    81, 82,
                                    90, 95),
                           "Landcover" = c("Open Water", "Perennial Ice/Snow",
                                           "Developed, Open Space", "Developed, Low Intensity", "Deveoped, Medium Intensity", "Developed, High Itensity",
                                           "Barren Land",
                                           "Deciduous Forest", "Evergreen Forest", "Mixed Forest",
                                           "Dwarf Scrub", "Shrub/Scrub",
                                           "Grassland/Herbaceous", "Sedge/Herbaceous", "Lichens", "Moss",
                                           "Pasture/Hay", "Cultivated Crops",
                                           "Woody Wetlands", "Emergent Herbaceous Wetlands"))

nlcd.rat <- merge(nlcd.rat, full.nlcd.df, by = "ID", all.x = TRUE)
levels(nlcd.cat) <- nlcd.rat
# plot(nlcd.cat)

# Categorize roads and water
roads.cat <- ratify(roads.lyr)
roads.rat <- levels(roads.cat)[[1]]
roads.rat$road <- c("Non-road", "Road")
levels(roads.cat) <- roads.rat
# plot(roads.cat)

water.cat <- ratify(water.lyr)
water.rat <- levels(water.cat)[[1]]
water.rat$StreamOrder <- c(NA, 1:7)
levels(water.cat) <- water.rat
# plot(water.cat)

water.cat.binary <- ratify(water.lyr)
water.cat.binary[water.cat.binary >= 1] <- 1
water.rat.binary <- data.frame("ID" = c(0,1))
water.rat.binary$StreamOrder <- c(NA, 1)
levels(water.cat.binary) <- water.rat.binary

water.cat.factor <- ratify(water.lyr)
water.cat.factor[water.cat.factor >= 1 & water.cat.factor < 5] <- 1
water.cat.factor[water.cat.factor >= 5] <- 2
water.rat.factor <- data.frame("ID" = c(0,1, 2))
water.rat.factor$StreamOrder <- c(NA, 1, 2)
levels(water.cat.factor) <- water.rat.factor

# *****************************************************************************
# Prepare inputs
# ****************************************************************************
# e <- c(-84.029, -83.005, 35.443, 35.762)
e <- c(-84.035, -82.995, 35.42, 35.80)
scale_covs <- raster::stack(scale(elevation.lyr), scale(slope.lyr), scale(canopy.lyr),
                            nlcd.cat,
                            roads.cat, water.cat, water.cat.binary, water.cat.factor) %>%
  crop(e) %>%
  raster::stack()
names(scale_covs) <- c("elevation", "slope", "canopy", "nlcd",
                       "roads", "water", "water_binary", "water_factor")
# small_e <- c(-83.65, -83.3, 35.5, 35.7)
small_e <- e
factor_val <- agg_fact
scale_covs_small <- crop(scale_covs, small_e) %>%
  raster::aggregate(fact = factor_val, fun = modal) %>%
  raster::stack()

# Reclassify all categorical data
# NLCD
scale_covs_small[["nlcd"]] <- ratify(scale_covs_small[["nlcd"]])
nlcd.rat.small <- levels(scale_covs_small[["nlcd"]])[[1]] %>%
  merge(full.nlcd.df, by = "ID", all.x = TRUE)
levels(scale_covs_small[["nlcd"]]) <- nlcd.rat.small

# Roads
scale_covs_small[["roads"]] <- ratify(scale_covs_small[["roads"]])
roads.rat.small <- levels(scale_covs_small[["roads"]])[[1]]
roads.rat.small$road <- c("Non-road", "Road")
levels(scale_covs_small[["roads"]]) <- roads.rat.small

# Water
scale_covs_small[["water"]] <- ratify(scale_covs_small[["water"]])
water.rat.small <- levels(scale_covs_small[["water"]])[[1]]
water.rat.small <- merge(water.rat.small,
                         water.rat, by = "ID", all.x = T)
levels(scale_covs_small[["water"]]) <- water.rat.small

# Water binary
scale_covs_small[["water_binary"]] <- ratify(scale_covs_small[["water_binary"]])
water.rat.binary.small <- levels(scale_covs_small[["water_binary"]])[[1]]
water.rat.binary.small <- merge(water.rat.binary.small,
                         water.rat.binary, by = "ID", all.x = T)
levels(scale_covs_small[["water_binary"]]) <- water.rat.binary.small

# Water factor
scale_covs_small[["water_factor"]] <- ratify(scale_covs_small[["water_factor"]])
water.rat.factor.small <- levels(scale_covs_small[["water_factor"]])[[1]]
water.rat.factor.small <- merge(water.rat.factor.small,
                         water.rat.factor, by = "ID", all.x = T)
levels(scale_covs_small[["water_factor"]]) <- water.rat.factor.small

# Sample coordinates
meta <- read_csv("./data/genotypes/buffer-10k/grsm-10k-meta.csv",
                 show_col_types = FALSE) %>%
  mutate(Long_jitter = jitter(Long, factor = 1),
         Lat_jitter = jitter(Lat, factor = 1),
         Long_lat = paste0(Long, "_", Lat),
         Long_lat_jitter = paste0(Long_jitter, "_", Lat_jitter))
ids.filter <- meta %>%
  filter(Long > small_e[1],
         Long < small_e[2],
         Lat > small_e[3],
         Lat < small_e[4])

input_samples <- SpatialPoints(coords = ids.filter[,c("Long", "Lat")])

# **********************************************************************
# Run Radish
# **********************************************************************
outname_covariates <- paste0("./data/radish/intermediary/30m_", agg_fact, "agg/covariates_", agg_fact, "agg.Rds")
saveRDS(scale_covs_small, outname_covariates)

# surface <- conductance_surface(covariates = scale_covs_small,
#                                coords = input_samples,
#                                directions = 8)

# outname_surface <- paste0("./data/radish/intermediary/30m_", agg_fact, "agg/conductance_surface_", agg_fact, "agg.Rds")
# saveRDS(surface, outname_surface)

# ids.index <- which(meta$SubjectID %in% ids.filter$SubjectID)
# pca.dist.mat <- readRDS("./data/radish/genetics/pca.dist.mat.Rds")
# gen_input <- pca.dist.mat[ids.index, ids.index]

# outname_gen_input <- paste0("./data/radish/intermediary/30m_", agg_fact, "agg/gen_input_", agg_fact, "agg.Rds")
# saveRDS(gen_input, outname_gen_input)





