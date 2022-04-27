## For clarification, write to <dhemerson.costa@ipam.org.br> and <felipe.lenti@ipam.org.br>
## Export yearly spectral signatures for each region and year to be used as training samples
## Exported data is composed by spatialPoints with spectral signature values grouped by column
## Auxiliary bands were computed (Lat, Long^2, NDVI Amp)

## read libraries
library(rgee)
ee_Initialize()

## define strings to use as metadata
version <- "1"     ## version string

## define output directory
dirout <- 'users/dh-conciani/collection7/training/v1/'

## define mosaic input 
mosaic = ee$ImageCollection('projects/nexgenmap/MapBiomas2/LANDSAT/BRAZIL/mosaics-2')$
  filterMetadata('biome', 'equals', 'CERRADO')

## import classification regions
regionsCollection <- ee$FeatureCollection('users/dh-conciani/collection7/classification_regions/vector')

## import sample points
samples <- ee$FeatureCollection('users/dh-conciani/collection7/sample/points/samplePoints_v5')

## define regions to extract spectral signatures (spatial operator)
regions_list <- unique(regionsCollection$aggregate_array('mapb')$getInfo())

## define years to extract spectral signatures (temporal operator)
years <- unique(mosaic$aggregate_array('year')$getInfo())

## get bandnames to be extracted
bands <- mosaic$first()$bandNames()$getInfo()

## remove bands with 'cloud' or 'shade' into their names
bands <- bands[- which(sapply(strsplit(bands, split='_', fixed=TRUE), function(x) (x[1])) == 'cloud' |
                        sapply(strsplit(bands, split='_', fixed=TRUE), function(x) (x[1])) == 'shade') ]
