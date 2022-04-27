## For clarification, write to <dhemerson.costa@ipam.org.br> 
## Exported data is composed by spatialPoints with spectral signature values grouped by column
## Auxiliary bands were computed (Lat, Long, NDVI amplitude and HAND)

## read libraries
library(rgee)
ee_Initialize()

## define strings to use as metadata
version <- "1"     ## version string

## define output directory
dirout <- 'users/dh-conciani/collection7/training/v1/'

## biome
biomes <- ee$Image('projects/mapbiomas-workspace/AUXILIAR/biomas-2019-raster')
cerrado <- biomes$updateMask(biomes$eq(4))

## define mosaic input 
mosaic <- ee$ImageCollection('projects/nexgenmap/MapBiomas2/LANDSAT/BRAZIL/mosaics-2')$
  filterMetadata('biome', 'equals', 'CERRADO')

## get mosaic rules
rules <- read.csv('./_aux/mosaic_rules.csv')

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

## for each region 
for (i in 1:length(regions_list)) {
  ## for each year
  for (j in 1:length(years)) {
 
  }
}

## print status
print(paste0('region ' , regions_list[1] , ' || year ' , years[1]))
## subset region
region_i <- regionsCollection$filterMetadata('mapb', "equals", regions_list[1])$geometry()

## compute additional bands
geo_coordinates <- ee$Image$pixelLonLat()$clip(region_i)
## get latitude
lat <- geo_coordinates$select('latitude')$add(5)$multiply(-1)$multiply(1000)$toInt16()
## get longitude
lon_sin <- geo_coordinates$select('longitude')$multiply(pi)$divide(180)$
  sin()$multiply(-1)$multiply(10000)$toInt16()$rename('longitude_sin')
## cosine
lon_cos <- geo_coordinates$select('longitude')$multiply(pi)$divide(180)$
  cos()$multiply(-1)$multiply(10000)$toInt16()$rename('longitude_cos')

## get heigth above nearest drainage
hand <- ee$ImageCollection("users/gena/global-hand/hand-100")$mosaic()$toInt16()$rename('hand')
years[1] <- 2002
## get the landsat mosaic for the current year 
mosaic_i <- mosaic$filterMetadata('year', 'equals', years[1])$
  filterMetadata('satellite', 'equals', subset(rules, year == years[1])$sensor)$
  mosaic()$select(bands)

## if the year is greater than 1986, get the 3yr NDVI amplitude
if (years[1] > 1986) {
  print('Computing NDVI Amplitude (3yr)')
  ## get previous year mosaic 
  mosaic_i1 <- mosaic$filterMetadata('year', 'equals', years[1] - 1)$
    filterMetadata('satellite', 'equals', subset(rules, year == years[1])$sensor_past1)$
    mosaic()$select(c('ndvi_median_dry','ndvi_median_wet'))
  ## get previous 2yr mosaic 
  mosaic_i2 <- mosaic$filterMetadata('year', 'equals', years[1] - 2)$
    filterMetadata('satellite', 'equals', subset(rules, year == years[1])$sensor_past2)$
    mosaic()$select(c('ndvi_median_dry','ndvi_median_wet'))
  
  ## compute the minimum NDVI over dry season 
  min_ndvi <- ee$ImageCollection$fromImages(c(mosaic_i$select('ndvi_median_dry'),
                                              mosaic_i1$select('ndvi_median_dry'),
                                              mosaic_i2$select('ndvi_median_dry')))$min()
  
  ## compute the mmaximum NDVI over wet season 
  max_ndvi <- ee$ImageCollection$fromImages(c(mosaic_i$select('ndvi_median_wet'),
                                              mosaic_i1$select('ndvi_median_wet'),
                                              mosaic_i2$select('ndvi_median_wet')))$max()
  
  ## get the amplitude
  amp_ndvi <- max_ndvi$subtract(min_ndvi)$rename('amp_ndvi_3yr');
}

## if the year[j] is lower than 1987, get null image as amp
if (years[1] < 1987){
  amp_ndvi <- ee$Image(0)$rename('amp_ndvi_3yr');
}


