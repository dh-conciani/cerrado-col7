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

## avoid scientific notation
options(scipen= 999)

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

## create recipe to receive data
recipe <- as.data.frame(NULL)

## for each region 
for (i in 1:length(unique(regions_list))) {
  print(paste0('processing region: ',  regions_list[i]))
  print(paste0(i, ' of ', length(regions_list)))
  
  ## get the vector of the region
  region_i <- regions$filterMetadata('mapb', 'equals', regions_list[i])
  
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
  
  ## for each file
  for(k in 1:length(unique(training$file))) {
    ## subset for the file
    temp_train <- subset(training, file== unique(training$file)[k])
    
    ## filter training dataset
    reference_class <- temp_train$reference
    
    ## remove strings from predictos dataset
    temp_train <- temp_train[- which(colnames(temp_train)== 'id')]
    temp_train <- temp_train[- which(colnames(temp_train)== 'reference')]
    temp_train <- temp_train[- which(colnames(temp_train)== 'file')]
    temp_train <- temp_train[- which(colnames(temp_train)== 'geometry')]
    
    ## create data partition (training 70%)
    trainingRows <- createDataPartition(reference_class, p = 1, list= FALSE)
    
    ## build training dataset
    trainPredictors <- temp_train[trainingRows, ]
    trainClasses <- reference_class[trainingRows]
    
    ## build validation dataset
    testPredictors <- as.data.frame(validation_signatures)
    testPredictors <- testPredictors[- which(colnames(testPredictors)== 'geometry')]
    testPredictors <- testPredictors[- which(colnames(testPredictors)== 'CLASS_2018')]
    ## create validation
    testClasses <- validation_signatures$CLASS_2018
    testClasses <- as.integer(gsub('Cultura Anual', 21,
                                   gsub('Cultura Semi-Perene', 21,
                                        gsub('Pastagem Cultivada', 21,
                                             gsub('Cultura Perene', 21,
                                                  gsub('Rio, Lago e Oceano', 33,
                                                       gsub('Formação Campestre', 12,
                                                            gsub('Formação Florestal', 3,
                                                                 gsub('Formação Savânica', 4,
                                                                      testClasses)))))))))
    
    ## create repetition estimates
    control <- trainControl(method="repeatedcv", number=5, repeats=3) 
    
    ## train randomForest 
    rfModel <- randomForest(trainPredictors, as.factor(trainClasses),
                            ntree= 100,
                            mtry= sqrt(ncol(trainPredictors)),
                            trControl= control,
                            preProc = c ("center", "scale"))
    
    
    ## perfom test by predcting unused dataset 
    rfTestPred <- predict (rfModel, testPredictors)
    
    ## remove 25
    testClasses <- testClasses[- which(rfTestPred == 25)]
    rfTestPred <- rfTestPred[- which(rfTestPred == 25)]
    
    ## convert all agro to 21
    rfTestPred <- gsub(15, 21,
                       gsub(19, 21,
                            gsub(21, 21,
                                 rfTestPred)))
    
    ## compute confusion matrix
    result_val <- confusionMatrix(data = as.factor(rfTestPred),
                                  reference = as.factor(testClasses))
    
    ## build results 
    toExport <- rbind(melt(result_val$overall), 
                      melt(result_val$byClass[,11]))
    toExport$variable <- row.names(toExport)
    toExport$balancing <- training$file[k]
    toExport$mapb <- regions_list[i]
    
    ## insert into recipe
    recipe <- rbind(recipe, toExport)
    ## clean memory
    rm(control, filtered_i, region_i, result_val, rfModel, samples_i, 
       temp_train, testPredictors, toExport, trainingRows, trainPredictors)
  }
}
