
# Changelog <br>
## 1_trainingMask:
  * Inclusion of new reference maps (TO)
  * Update of the PRODES deforestation database (2000 to 2021) 
  * Inclusion of canopy heigth (GEDI derived) to filter stable pixels

## 2_computeProportion:
  * Code structure optmization. Inclusion of .map functions instead repetition 

## 3_createPoints:
  * Code structure optmization. Inclusion of .map functions instead repetition 

## 4_getSignatures.R:
  * Migration from python api to R api (rgee)
  * inclusion of the time since the last fire as predictor
  * Inclusion of derived longitude geo-descriptors (sin, cos)
  * inclusion of HAND as predictor 
  * Inclusion the auxMosaics inside this step

## 5_rfClassification.R:
  * Migration from python api to R api (rgee)
  * ntree optimization (from 100 to 300)
  * mtry optimization (form sqrt(predictors) to 12)  

## 6_gapfill.js:
  * The filter has become more restrictive, changes only edge pixels that have had more than 19 changes over the series (50% of the time +1), does not change native vegetation packages 

## 7_incidence.js:
  * code optimization (from 240 to 83 lines)
  * dont use wetland as mode filter 

## 8_temporal.js:
  * rewriten to new sintax 
  * rules reviewed and optimized following cerrado ecology
  * wetlands included 
 
 ## 9_frequency.js:
  * stabilize pixels that are native vegetation for at least 95% of the time

 
 ## 10_spatial.js:
  * double filtering
  * minimum mapping area equals to 0.45 ha
 



