library(sf)
library(tigris)
library(tidyverse)

# Load in Kontur dataset
data <- st_read("data/kontur_population_US_20220630.gpkg")

# Load states
st <- states()

# Filter for Texas
texas <- st |>
  filter(NAME == "Texas")

# Check the map
texas |>
  ggplot() + 
  geom_sf()