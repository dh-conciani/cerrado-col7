/**
 * Script modelo para padronização dos assets do Mapbiomas~
 */

var palette = require('users/mapbiomas/modules:Palettes.js').get('classification6');

// Defina seu asset de entrada
var assetInput = 'users/dh-conciani/collection7/c7-general-post';
var file_name = 'CERRADO_col7_native9_rocky3';

// Carregue a sua coleção aqui
var collection = ee.Image(assetInput + '/' + file_name);

// Defina seu asset de saída
var assetOutput = 'projects/mapbiomas-workspace/COLECAO7/classificacao';

// Defina a versão de saída
var outputVersion = '1';

// Defina o id de lançamento da coleção mapbiomas
var collectionId = 7.0;

// Se for bioma use este.
var theme = { 'type': 'biome', 'name': 'CERRADO' };
// Se for tema transversal use este.
// var theme = { 'type': 'theme', 'name': 'INFRAURBANA'};

// Defina a fonte produto do dado
var source = 'ipam';

// Todos os anos mapeados na coleção 6
var years = [
    '1985', '1986', '1987', '1988',
    '1989', '1990', '1991', '1992',
    '1993', '1994', '1995', '1996',
    '1997', '1998', '1999', '2000',
    '2001', '2002', '2003', '2004',
    '2005', '2006', '2007', '2008',
    '2009', '2010', '2011', '2012',
    '2013', '2014', '2015', '2016',
    '2017', '2018', '2019', '2020',
    '2021'
];

// Boundary box de todo o Brasil
var geometry = ee.Geometry.Polygon(
    [
        [
            [-75.46319738935682, 6.627809464162168],
            [-75.46319738935682, -34.62753178950752],
            [-32.92413488935683, -34.62753178950752],
            [-32.92413488935683, 6.627809464162168]
        ]
    ], null, false
);

years.forEach(
    function (year) {

        var imageYear = collection.select('classification_' + year);

        imageYear = imageYear.rename('classification');

        imageYear = imageYear
            .set('territory', 'BRAZIL')
            .set('biome', 'CERRADO')
            .set('year', parseInt(year, 10))
            .set('version', outputVersion)
            .set('collection', collectionId)
            .set('source', source)
            .set('description', 'native9_rocky3');

        var vis = {
            'min': 0,
            'max': 49,
            'palette': palette,
            'format': 'png'
        };

       var name = year + '-' + outputVersion;

        if (theme.type === 'biome') {
            name = theme.name + '-' + name;
        }
        
        print(imageYear);
        
        // perform reclassification of mosaic of agriculture and pasture to pasture into protected areas (except APAs and TIs)
        // build mask
        // import protected areas
        var pa = ee.Image(1).clip(
                    ee.FeatureCollection('projects/mapbiomas-workspace/AUXILIAR/areas-protegidas')
                            .filterMetadata('categoria', 'not_equals', 'APA')
                            .filterMetadata('categoria', 'not_equals', ''));

        // remap
        imageYear = imageYear.where(imageYear.eq(21).and(pa.eq(1)), 15);
        
        Map.addLayer(imageYear, vis, theme.name + ' ' + year, false);

        Export.image.toAsset({
            'image': imageYear,
            'description': name,
            'assetId': assetOutput + '/' + name,
            'pyramidingPolicy': {
                '.default': 'mode'
            },
            'region': geometry,
            'scale': 30,
            'maxPixels': 1e13
        });
    }
);
