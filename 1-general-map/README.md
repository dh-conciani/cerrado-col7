
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
  * Inclusion of derived longitude geo-descriptors
  * inclusion of HAND as predictor 
  * Inclusion the auxMosaics inside this step
