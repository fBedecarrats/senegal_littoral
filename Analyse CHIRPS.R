# Install geoarrow if not available
if (!"geoarrow" %in% installed.packages()) {
  remotes::install_github("paleolimbot/geoarrow", upgrade = "never")
}

# Load librairies
library(aws.s3)
library(tidyverse) # toolkit for data manipulation
library(geodata) # to get municipalities
library(sf) # to handle spatial data (vectors)
library(terra) # to handle patial data (rasters)
library(mapme.biodiversity) # to compute spatial indicators
library(tmap) # nice maps
library(zoo) # time series
library(units) # ensures units are right
library(future) # to parallelize computations
library(exactextractr) # engine for mapme.biodiversity
library(SPEI) # to compute rainfall  
library(geoarrow) # to write/read efficient spatial vector format
library(progressr) # for progress bars


# Download Senegal municipalities as areas of interest
aoi <- gadm("SEN", level  = 3, path = "data") %>%
  st_as_sf()  %>%
  st_cast("POLYGON")

aoi <- init_portfolio(aoi, years = 1990:2020,
                      outdir = "data", add_resources = TRUE) 

# we use parallel computing to reduce processing time
plan(multisession, workers = 8)

# Resrouces should be already present
aoi <- aoi %>%
  get_resources("chirps")

# Compute precipitation indicators
with_progress({ # to have a progress bar 
  aoi <- aoi %>%
    calc_indicators("precipitation_chirps",
                    engine = "exactextract",
                    scales_spi = 3,
                    spi_prev_years = 8)
}) # progress bar does not seem to work

# We compute 3 days average precipitations
precip_3d <- aoi %>%
  unnest(precipitation_chirps) %>%
  group_by(name) %>%
  mutate(rainfall_3d_mean = rollmean(absolute, k = 3, fill = NA))


