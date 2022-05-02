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
var nClasses = classification.reduce(ee.Reducer.countDistinctNonNull()).rename('number_of_classes');

// compute the mode
var mode = classification.reduce(ee.Reducer.mode());

// plot on the map
// number of changes
Map.addLayer(nChanges, {palette: ["#C8C8C8", "#FED266", "#FBA713", "#cb701b", "#a95512", "#662000", "#cb181d"],
                                  min: 0, max: 15}, 'number of changes');
 
// number of classes
Map.addLayer(nClasses, {palette: [ "#ffffff", "#C8C8C8", "#AE78B2", "#772D8F", "#4C226A", "#22053A"],
                                  min: 0, max: 5}, 'number of classes');
                                  
// classification
Map.addLayer(mode, vis, 'mode');
Map.addLayer(classification.select(['classification_2021']), vis, 'classification');
Map.addLayer(classification, {}, 'all', false);
