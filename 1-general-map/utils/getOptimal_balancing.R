## get balancing parameters and perform adjustment
## dhemerson.costa@ipam.org.br

## load packages
library(rgee)
library(sf)
library(caret)
library(randomForest)
library(AppliedPredictiveModeling)
library(reshape2)
library(DMwR2)


## initialize earth engine 
ee_Initialize()

## load unfiltered samples 
samples <- ee$FeatureCollection('users/dh-conciani/collection7/sample/points/samplePoints_v3')

## load filtered samples
filtered <- ee$FeatureCollection('users/dh-conciani/collection7/sample/filtered_points/consolidated/samplePoints_filtered_v3')

## load classification regions
regions <- ee$FeatureCollection('users/dh-conciani/collection7/classification_regions/vector')

## set classes to select from validation dataset
selectClasses = c(
  "Rio, Lago e Oceano",
  "Formação Savânica",
  "Formação Florestal",
  "Formação Campestre",
  "Pastagem Cultivada",
  "Cultura Anual",
  "Cultura Perene",
  "Cultura Semi-Perene"
  ) 

## load validation points from LAPIG
validation <- ee$FeatureCollection('projects/mapbiomas-workspace/VALIDACAO/MAPBIOMAS_100K_POINTS_utf8')$
  filterBounds(regions)$
  filterMetadata('POINTEDITE', 'not_equals', 'true')$
  select('CLASS_2018')$
  filter(ee$Filter$inList('CLASS_2018', selectClasses))

## load landsat mosaic
landsat <- ee$ImageCollection('projects/nexgenmap/MapBiomas2/LANDSAT/BRAZIL/mosaics-2')$
  filterMetadata('biome', 'equals', 'CERRADO')$
  filterMetadata('year', 'equals', 2018)$
  mosaic()

## get the number of unique regions
regions_list <- unique(regions$aggregate_array('mapb')$getInfo())

## for each region 
for (i in 1:length(unique(regions_list))) {
  ## run function
}

## get the vector of the region
region_i <- regions$filterMetadata('mapb', 'equals', regions_list[14])

## filter unfiltered, filtered and validation 
samples_i <- samples$filterBounds(region_i)
filtered_i <- filtered$filterBounds(region_i)
validation_i <- validation$filterBounds(region_i)

## extract spectral signatures for the raw dataset 
samples_training <- na.omit(ee_as_sf(landsat$sampleRegions(collection= samples_i,
                                                    scale= 30,
                                                    geometries= TRUE,
                                                    tileScale= 2), 
                                     via = 'drive'))

## insert metadata
samples_training$file <- 'original'
#$ remove mapb column
samples_training <- samples_training[-48]

## if the size of the filtered dataset is greater than 20k, performin sampling (to avoid memory error)
if (filtered_i$size()$getInfo() > 20000) {
  print('size of filtered greater than 20k -> filtering [0.6]')
  ## compute random column
  filtered_i <- filtered_i$randomColumn()
  ## subset 60% randomly
  filtered_i <- filtered_i$filter(ee$Filter$lt('random', 0.6))
} 
## extract signatures
filtered_training <- na.omit(ee_as_sf(landsat$sampleRegions(collection= filtered_i,
                                                           scale= 30,
                                                           geometries= TRUE,
                                                           tileScale= 2), 
                                      via = 'drive'))

## insert metadata
filtered_training$file <- 'filtered_raw'
## remove random column
filtered_training <- filtered_training[-80]

## extract signature for validation
validation_signatures <- na.omit(ee_as_sf(landsat$sampleRegions(collection= validation_i,
                                                                scale= 30,
                                                                geometries= TRUE,
                                                                tileScale= 2), via = 'getInfo'))

## merge datasets
training <- as.data.frame(rbind(samples_training, filtered_training))
rm(samples_training, filtered_training)

## filter training dataset
reference_class <- training$reference
reference_file <- training$file

## remove strings from predictos dataset
training <- training[- which(colnames(training)== 'reference')]
training <- training[- which(colnames(training)== 'geometry')]

## for each file
for(k in 1:length(unique(reference_file))) {
  print(unique(reference_file)[k])
}

## subset for the file
temp_train <- subset(training, file== unique(reference_file)[1])

## build map
Map$addLayer(region_i) +
  Map$addLayer(samples_i) +
  Map$addLayer(filtered_i) +
  Map$addLayer(validation_i) +
  ## visualize mosaic
  Map$addLayer(landsat, list(bands= c('swir1_median', 'nir_median', 'red_median'),  
                             gain= c(0.08, 0.06, 0.2),
                             gamma= 0.85), 'Lansat')

  
