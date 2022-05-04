// filter spurious transitions by using number of changes and number of classes 
// for clarification write to dhemerson.costa@ipam.org.br

// set root imageCollection
var root = 'users/dh-conciani/collection7/c7-general-post/';

// set version
var input_version = '1';
var output_version = '1';

// define input file 
var file_in = 'CERRADO_col7_gapfill_v' + input_version;

// import mapbiomas color ramp
var vis = {
    'min': 0,
    'max': 49,
    'palette': require('users/mapbiomas/modules:Palettes.js').get('classification6')
};

// load input
var classification = ee.Image(root + file_in);

// compute number of classes and changes 
var nChanges = classification.reduce(ee.Reducer.countRuns()).subtract(1).rename('number_of_changes');

// get the count of connections
var connected_nChanges = nChanges.connectedPixelCount({
      'maxSize': 100, 
      'eightConnected': false});

// compute the mode
var mode = classification.reduce(ee.Reducer.mode());

// plot 
// number of changes
Map.addLayer(nChanges, {palette: ["#C8C8C8", "#FED266", "#FBA713", "#cb701b", "#a95512", "#662000", "#cb181d"],
                                  min: 0, max: 15}, 'number of changes', false);

Map.addLayer(connected_nChanges, {palette: ['green', 'yellow', 'orange', 'red'], min:0, max:10}, 'con. nChanges', false);

// classification
Map.addLayer(mode, vis, 'mode', false);
Map.addLayer(classification.select(['classification_2021']), vis, 'classification');

// get border pixels (high geolocation RMSE) to be masked by the mode
var border_mask = connected_nChanges.lte(6).and(nChanges.gt(12));
border_mask = border_mask.updateMask(border_mask.eq(1));    

// get borders to rectfy
var rect_border = mode.updateMask(border_mask);
//Map.addLayer(rect_border, vis, 'border to rect');

// get forests to rectfy
var forest = connected_nChanges.gt(6).and(nChanges.gt(12)).and(mode.eq(3));
forest = ee.Image(3).updateMask(forest);
//Map.addLayer(forest, vis, 'forest');

// get savanna to rectfy 
var savanna = connected_nChanges.gt(6).and(nChanges.gt(12)).and(mode.eq(4));
savanna = ee.Image(4).updateMask(savanna);

// get wetland to rectfy 
var wetland = connected_nChanges.gt(6).and(nChanges.gt(12)).and(mode.eq(11));
wetland = ee.Image(11).updateMask(wetland);

// get grassland to rectfy 
var grassland = connected_nChanges.gt(6).and(nChanges.gt(12)).and(mode.eq(12));
grassland = ee.Image(12).updateMask(grassland);

// get pasture to rectfy 
var pasture = connected_nChanges.gt(6).and(nChanges.gt(12)).and(mode.eq(15));
pasture = ee.Image(15).updateMask(pasture);

// get agriculture to rectfy 
var agriculture = connected_nChanges.gt(6).and(nChanges.gt(12)).and(mode.eq(19));
agriculture = ee.Image(19).updateMask(agriculture);

// get mosaic to rectfy 
var mosaic = connected_nChanges.gt(6).and(nChanges.gt(12)).and(mode.eq(21));
mosaic = ee.Image(21).updateMask(mosaic);

// build rect mask

