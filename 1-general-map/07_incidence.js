// filter spurious transitions by using the number of changes, connections and mode reducer
// for clarification write to dhemerson.costa@ipam.org.br

// set root imageCollection
var root = 'users/dh-conciani/collection7/c7-general-post/';

// set version
var input_version = '2';
var output_version = '6';

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

// remove wetlands from incidents filter
//var classification_remap = classification.updateMask(classification.neq(11));

// compute number of classes and changes 
var nChanges = classification.reduce(ee.Reducer.countRuns()).subtract(1).rename('number_of_changes');

// get the count of connections
var connected_nChanges = nChanges.connectedPixelCount({
      'maxSize': 100, 
      'eightConnected': false});

// compute the mode
var mode = classification.reduce(ee.Reducer.mode());

// plot raw
Map.addLayer(classification.select(['classification_1985']), vis, 'classification');

// get border pixels (high geolocation RMSE) to be masked by the mode
var border_mask = connected_nChanges.lte(6).and(nChanges.gt(19));
border_mask = border_mask.updateMask(border_mask.eq(1));    

// get borders to rectfy
var rect_border = mode.updateMask(border_mask);
Map.addLayer(rect_border, vis, 'border', false);

// apply border
classification = classification.blend(rect_border);

/*

// compute the mode
var mode_after = classification.reduce(ee.Reducer.mode());

// compute number of classes and changes 
var nChanges_after = classification.reduce(ee.Reducer.countRuns()).subtract(1).rename('number_of_changes');

// get the count of connections
var connected_nChanges_after = nChanges_after.connectedPixelCount({
      'maxSize': 100, 
      'eightConnected': false});


// plot 
// number of changes
Map.addLayer(nChanges_after, {palette: ["#C8C8C8", "#FED266", "#FBA713", "#cb701b", "#a95512", "#662000", "#cb181d"],
                                  min: 0, max: 15}, 'number of changes', false);

Map.addLayer(connected_nChanges_after, {palette: ['green', 'yellow', 'orange', 'red'], min:0, max:10}, 'con. nChanges', false);

// classification
Map.addLayer(mode_after, vis, 'mode', false);

// get native classes to remove behavior similar to forestry
var forest = ee.Image(3).updateMask(connected_nChanges_after.gt(55).and(nChanges_after.gt(12)).and(mode_after.eq(3)));
var savanna = ee.Image(4).updateMask(connected_nChanges_after.gt(55).and(nChanges_after.gt(12)).and(mode_after.eq(4)));
var grassland = ee.Image(12).updateMask(connected_nChanges_after.gt(55).and(nChanges_after.gt(12)).and(mode_after.eq(12)));
var wetland = ee.Image(11).updateMask(connected_nChanges_after.gt(55).and(nChanges_after.gte(12)).and(mode_after.eq(11)));

// blend masks
var incidentsMask = rect_border.blend(forest)
                               .blend(savanna)
                               .blend(grassland)
                               .blend(wetland)
                               .toByte();

// build correction
classification = classification.blend(incidentsMask);
Map.addLayer(classification.select(['classification_1985']), vis, 'rectified');

*/

// export as GEE asset
Export.image.toAsset({
    'image': classification,
    'description': 'CERRADO_col7_gapfill_incidence_v' + output_version,
    'assetId': root + 'CERRADO_col7_gapfill_incidence_v' + output_version,
    'pyramidingPolicy': {
        '.default': 'mode'
    },
    'region': classification.geometry(),
    'scale': 30,
    'maxPixels': 1e13
});
