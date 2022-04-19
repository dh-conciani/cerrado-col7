## get balancing parameters and perform adjustment
## dhemerson.costa@ipam.org.br

## load packages
library(rgee)
library(sf)

## initialize earth engine 
ee_Initialize()

## load unfiltered samples 
samples <- ee_as_sf(ee$FeatureCollection('users/dh-conciani/collection7/sample/points/samplePoints_v2'), 
                    maxFeatures= 1000000,
                    via= 'getInfo')

## load samples filtered by segments
filtered <- ee_as_sf(ee$FeatureCollection('users/dh-conciani/collection7/sample/filtered_points/consolidated/samplePoints_filtered_v2'),
                     maxFeatures= 1000000,
                     via= 'getInfo')

filtered$first()$getInfo()
