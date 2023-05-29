library(sf)
library(tigris)
library(tidyverse)

# Load in Kontur dataset
data <- st_read("data/kontur_population_US_20220630.gpkg")

# Load states
st <- states()

# Filter for Texas
texas <- st |>
  filter(NAME == "Texas") |>
  st_transform(crs = st_crs(data))

# Check the map
texas |>
  ggplot() + 
  geom_sf()

# Perform an intersection operation on the data to restrict contours to the geographical boundaries of Texas.
st_texas <- st_intersection(data, texas)

# Define aspect ratio based on bounding box
bb <- st_bbox(st_texas)

bottom_left <- st_point(c(bb[["xmin"]], bb[["ymin"]])) |>
  st_sfc(crs = st_crs(data))

bottom_right <- st_point(c(bb[["xmax"]], bb[["ymin"]])) |>
  st_sfc(crs = st_crs(data))

texas |>
  ggplot() + 
  geom_sf() + 
  geom_sf(data = bottom_left) + 
  geom_sf(data = bottom_right, color = "blue")

