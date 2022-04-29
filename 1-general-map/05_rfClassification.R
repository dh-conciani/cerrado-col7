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

## define output asset
output_asset <- 'projects/mapbiomas-workspace/COLECAO6/classificacao-test/'

## read landsat mosaic 
mosaic <- ee$ImageCollection('projects/nexgenmap/MapBiomas2/LANDSAT/BRAZIL/mosaics-2')$
  filterMetadata('biome', 'equals', 'CERRADO')

## define years to be classified
years <- unique(mosaic$aggregate_array('year')$getInfo())

## read classification regions (vetor)
regions_vec <- ee$FeatureCollection('users/dh-conciani/collection7/classification_regions/vector')

## define regions to be processed 
regions_list <- sort(unique(regions_vec$aggregate_array('mapb')$getInfo()))

## get predictor names to be used in the classification
bands <- mosaic$first()$bandNames()$getInfo()

## remove bands with 'cloud' or 'shade' into their names
bands <- bands[- which(sapply(strsplit(bands, split='_', fixed=TRUE), function(x) (x[1])) == 'cloud' |
                         sapply(strsplit(bands, split='_', fixed=TRUE), function(x) (x[1])) == 'shade') ]

## add auxiliary bandnames
bands <- c(bands, 'latitude', 'longitude_sin', 'longitude_cos', 'hand', 'amp_ndvi_3yr')

## define assets
### training samples (prefix string)
training_samples <- 'users/dh-conciani/collection7/training/'

### classification regions (imageCollection, one region per image)
regions_ic <- ee$ImageCollection('users/dh-conciani/collection7/classification_regions/eachRegion')

## for each region
for (i in 1:length(regions_list)) {
  print(paste0('processing region [', regions_list[i], ']'))
  ## get the vector for the region [i]
  
  for (j in 1:length(years)) {
    print(paste0('----> ', years[j]))
  }
}

## get the vector for the regon [i]
region_i_vec <- regions_vec$filterMetadata('mapb', 'equals', regions_list[37])$geometry()
## get the raster for the region [i]
region_i_ras = regions_ic$filterMetadata('mapb', 'equals', as.character(regions_list[37]))$mosaic()


