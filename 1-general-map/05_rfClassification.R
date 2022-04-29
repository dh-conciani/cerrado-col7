## Run smileRandomForest classifier - Mapbiomas Collection 7.0
## For clarification, write to <dhemerson.costa@ipam.org.br> 

## import libraries
library(rgee)
ee_Initialize()

## define strings to be used as metadata
samples_version <- '1'   # input training samples version
output_version <-  '1'   # output classification version 

## define hyperparameters for then rf classifier
n_tree <- 250

## read landsat mosaic 
mosaic <- ee$ImageCollection('projects/nexgenmap/MapBiomas2/LANDSAT/BRAZIL/mosaics-2')$
  filterMetadata('biome', 'equals', 'CERRADO')

## define years to be classified
years <- unique(mosaic$aggregate_array('year')$getInfo())

## read classification regions (vetor)
regions_vec <- ee$FeatureCollection('users/dh-conciani/collection7/classification_regions/vector')

## define regions to be processed 
regions_list <- sort(unique(regions_vec$aggregate_array('mapb')$getInfo()))
