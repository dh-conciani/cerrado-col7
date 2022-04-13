## function to rasterize vector into geoTif
## dhemerson.costa@ipam.org.br

library(stars)
library(sf)
library(raster)

vec_to_raster <- function(vector, resolution, field_name, parameter, output) {

}


## read vector
file <- read_sf('../collection7/classification_regions_col7.shp')

## create mask
mask <- raster(crs=projection(file), ext= extent(file))

## set resolution
res(mask) = 0.001

## rasterize
raster_file <- rasterize(x= file, y= mask, field= 'mapb', fun= 'min', progress='text')

writeRaster(raster_file, '../collection7/classification_regions_col7_raster_max.tif', drive="GTiff")
