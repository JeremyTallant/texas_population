library(sf)
library(tigris)
library(tidyverse)
library(stars)
library(rayshader)
library(MetBrewer)
library(colorspace)

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

# Check points by plotting 
texas |>
  ggplot() + 
  geom_sf() + 
  geom_sf(data = bottom_left) + 
  geom_sf(data = bottom_right, color = "blue")

width <- st_distance(bottom_left, bottom_right)

top_left <- st_point(c(bb[["xmin"]], bb[["ymax"]])) |>
  st_sfc(crs = st_crs(data))

height <- st_distance(bottom_left, top_left)

# Handle conditions of width and height 
if (width > height) {
  w_ratio <- 1
  h_ratio <- height / width
} else {
  h_ratio <- 1
  w_ratio <- width / height
}

# Convert to raster to then convert to matrix
size <- 1000
texas_rast <- st_rasterize(st_texas,
                           nx = floor(size * w_ratio),
                           ny = floor(size * h_ratio))

mat <- matrix(texas_rast$population,
              nrow = floor(size * w_ratio),
              ncol = floor(size * h_ratio))

# Create color pallete 
c1 <- met.brewer("OKeeffe2")
swatchplot(c1)

texture <- grDevices::colorRampPalette(c1, bias = 2)(256)
swatchplot(texture)

# Plot 3d object

mat |>
  height_shade(texture = texture) |>
  plot_3d(heightmap = mat, 
          zscale = 100,
          solid = FALSE,
          shadowdepth = 0)

render_camera(theta = -20, phi = 45, zoom = .8)