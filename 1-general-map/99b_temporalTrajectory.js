// temporal filter - cerrado biome 
// dhemerson.costa@ipam.org.br

// set root directory 
var root = 'users/dh-conciani/collection7/c7-general-post/';

// set file to be processed
var file_in = 'CERRADO_col7_gapfill_incidence_v1';

// set metadata to export 
var version_out = '1';

// import mapbiomas color ramp
var vis = {
    'min': 0,
    'max': 49,
    'palette': require('users/mapbiomas/modules:Palettes.js').get('classification6')
};

// import classification 
var inputClassification = ee.Image(root + file_in);

////////////////////////////// set rules to avoid deforestations from forest to grassland (or other inconsistent classes)
// three years
var rule_3yr_deforestation = function(class_id, year, image) {
  var to_mask = image.select(['classification_' + String(year - 1)]).eq(class_id[0])   // previous
           .and(image.select(['classification_' + year]).eq(class_id[1]))              // current
           .and(image.select(['classification_' + String(year + 1)]).eq(class_id[2])); // next
           
  // when transitions occurs from class_id 0 to 2, passing for the 1, use the value 3
    return image.select(['classification_' + year])
              .where(to_mask.eq(1), class_id[3]);
};

// four years
var rule_4yr_deforestation = function(class_id, year, image) {
  var to_mask = image.select(['classification_' + String(year - 1)]).eq(class_id[0])   // previous
           .and(image.select(['classification_' + year]).eq(class_id[1]))      // current
           .and(image.select(['classification_' + String(year + 1)]).eq(class_id[2]))  // next
           .and(image.select(['classification_' + String(year + 2)]).eq(class_id[3])); // next

           
  // when transitions occurs from class_id 0 to 3, passing for the 1 or 2, use the value 4
    return image.select(['classification_' + year])
              .where(to_mask.eq(1), class_id[4]);
};

////////////////////// set functions to apply rules over the time-series for deforestation
// three years
var run_3yr_deforestation = function(image, class_id) {
  // create recipe with the first year (without previous year)
  var recipe = image.select(['classification_1985']);
   // for each year in the window
  ee.List.sequence({'start': 1986, 'end': 2020 }).getInfo()
      .forEach(function(year_i){
        // run filter
        recipe = recipe.addBands(rule_3yr_deforestation(class_id, year_i, image));
      }
    );
  // insert last years (without suitable next yr to apply filter)
  recipe = recipe.addBands(image.select(['classification_2021'])); 
  
  return recipe;
};

// four years
var run_4yr_deforestation = function(image, class_id) {
  // create recipe with the first year (without previous year)
  var recipe = image.select(['classification_1985']);
   // for each year in the window
  ee.List.sequence({'start': 1986, 'end': 2019 }).getInfo()
      .forEach(function(year_i){
        // run filter
        recipe = recipe.addBands(rule_4yr_deforestation(class_id, year_i, image));
      }
    );
  // insert last years (without suitable next yr to apply filter)
  recipe = recipe.addBands(image.select(['classification_2020']))
                 .addBands(image.select(['classification_2021'])); 
  
  return recipe;
};

var to_filter = inputClassification;

// run custom filters
// 4 yr
to_filter = run_4yr_deforestation(to_filter, [4, 21, 25, 3, 4]);
to_filter = run_4yr_deforestation(to_filter, [12, 25, 11, 3, 12]);
to_filter = run_4yr_deforestation(to_filter, [4, 25, 11, 3, 12]);
to_filter = run_4yr_deforestation(to_filter, [3, 12, 25, 25, 3]);
to_filter = run_4yr_deforestation(to_filter, [3, 25, 25, 4, 3]);
to_filter = run_4yr_deforestation(to_filter, [12, 25, 25, 4, 12]);
to_filter = run_4yr_deforestation(to_filter, [12, 4, 4, 11, 12]);
to_filter = run_4yr_deforestation(to_filter, [11, 3,  3, 3, 11]);
to_filter = run_4yr_deforestation(to_filter, [11, 3, 3, 11, 11]);
to_filter = run_4yr_deforestation(to_filter, [3, 21, 12, 25, 12]);
to_filter = run_4yr_deforestation(to_filter, [25, 12, 12, 25, 25]);
to_filter = run_4yr_deforestation(to_filter, [3, 21, 21, 11, 3]);
to_filter = run_4yr_deforestation(to_filter, [4, 12 ,12, 3, 4]);
to_filter = run_4yr_deforestation(to_filter, [3, 11, 11, 12, 12]);
to_filter = run_4yr_deforestation(to_filter, [3, 21, 11, 11, 3]);
to_filter = run_4yr_deforestation(to_filter, [3, 11, 4, 12, 3]);
to_filter = run_4yr_deforestation(to_filter, [12, 11, 11, 3, 12]);
to_filter = run_4yr_deforestation(to_filter, [12, 21, 21, 4, 4]);
to_filter = run_4yr_deforestation(to_filter, [3, 11, 11, 4, 3]);
to_filter = run_4yr_deforestation(to_filter, [4, 25, 12, 12, 12]);

// 3 yr
to_filter = run_3yr_deforestation(to_filter, [4, 25, 3, 4]);
to_filter = run_3yr_deforestation(to_filter, [3, 21, 4, 3]);
to_filter = run_3yr_deforestation(to_filter, [4, 11, 3, 4]);
to_filter = run_3yr_deforestation(to_filter, [3, 11, 3, 3]);
to_filter = run_3yr_deforestation(to_filter, [12, 25, 21, 21]);
to_filter = run_3yr_deforestation(to_filter, [4, 12, 12, 4]);
to_filter = run_3yr_deforestation(to_filter, [4, 12, 25, 4]);
to_filter = run_3yr_deforestation(to_filter, [12, 25, 3, 12]);
to_filter = run_3yr_deforestation(to_filter, [12, 25, 11, 12]);
to_filter = run_3yr_deforestation(to_filter, [4, 25, 11, 4]);
to_filter = run_3yr_deforestation(to_filter, [12, 11, 3, 12]);
to_filter = run_3yr_deforestation(to_filter, [3, 25, 4, 3]);
to_filter = run_3yr_deforestation(to_filter, [12, 25, 4, 12]);
to_filter = run_3yr_deforestation(to_filter, [12, 4, 11, 12]);
to_filter = run_3yr_deforestation(to_filter, [25, 12, 3, 3]);
to_filter = run_3yr_deforestation(to_filter, [3, 11, 12, 12]);
to_filter = run_3yr_deforestation(to_filter, [12, 3, 4, 12]);
to_filter = run_3yr_deforestation(to_filter, [11, 12, 25, 11]);
to_filter = run_3yr_deforestation(to_filter, [11, 25, 3, 3]);
to_filter = run_3yr_deforestation(to_filter, [4, 12, 3, 4]);
to_filter = run_3yr_deforestation(to_filter, [25, 12, 25, 25]);
to_filter = run_3yr_deforestation(to_filter, [3, 21, 11, 11]);
to_filter = run_3yr_deforestation(to_filter, [12, 11, 12, 12]);
to_filter = run_3yr_deforestation(to_filter, [3, 4, 12, 12]);
to_filter = run_3yr_deforestation(to_filter, [12, 21, 4, 4]);
to_filter = run_3yr_deforestation(to_filter, [4, 3, 12, 4]);
to_filter = run_3yr_deforestation(to_filter, [3, 11, 4, 3]);
to_filter = run_3yr_deforestation(to_filter, [12, 4, 21, 12]);
to_filter = run_3yr_deforestation(to_filter, [12, 21, 4 ,12]);
