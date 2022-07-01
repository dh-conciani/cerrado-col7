/**
 * Script modelo para padronização dos assets do Mapbiomas~
 */

// geometria para corrigir campo para afloramento 
var geometry_mask = ee.Image(1).clip(ee.FeatureCollection(ee.Geometry.MultiPolygon(
        [[[[-43.54367578400043, -18.53690253927378],
           [-43.54607904327777, -18.509557440463933],
           [-43.552945498355896, -18.496860015981152],
           [-43.58762109650043, -18.489696950925],
           [-43.614400271305115, -18.515743024006678],
           [-43.61646020782855, -18.52583481176097],
           [-43.62298334015277, -18.529090100124872],
           [-43.632596377262146, -18.544063628062915],
           [-43.65044916046527, -18.54927150407182],
           [-43.654569033512146, -18.538204577743524],
           [-43.66692865265277, -18.537553559748883],
           [-43.676541689762146, -18.55480469829488],
           [-43.684094790348084, -18.54504011691155],
           [-43.69885766876605, -18.551875382515696],
           [-43.70641076935199, -18.558710374469605],
           [-43.711560610660584, -18.567823271247534],
           [-43.714307192691834, -18.573030422263557],
           [-43.71533716095355, -18.577261115383273],
           [-43.720487002262146, -18.58409509016656],
           [-43.72117364776996, -18.59450823901314],
           [-43.720487002262146, -18.60492075119571],
           [-43.71739709747699, -18.616959424352938],
           [-43.72735345734027, -18.62541852281276],
           [-43.72460687530902, -18.638431698519668],
           [-43.717740420230896, -18.666081386480315],
           [-43.613370303043396, -18.68624655189411],
           [-43.55088556183246, -18.682669036326683],
           [-43.53234613312152, -18.617935495650585],
           [-43.53571571149347, -18.5616395729437]]],
         [[[-43.68437446393487, -18.77937018612342],
           [-43.674074781317685, -18.759216126441153],
           [-43.68952430524347, -18.703617456592323],
           [-43.71836341657159, -18.660036136969975],
           [-43.735186231513, -18.65645806831971],
           [-43.765741956610654, -18.65353050148915],
           [-43.7846247080755, -18.660686686799753],
           [-43.78050483502862, -18.686381408998123],
           [-43.770205152411435, -18.704593029452703],
           [-43.77089179791925, -18.713698104915327],
           [-43.75681556500909, -18.75401468779212],
           [-43.72660316266534, -18.773519255707004],
           [-43.713213575263, -18.77611969430262]]]])));
           
var palette = require('users/mapbiomas/modules:Palettes.js').get('classification6');

// Defina seu asset de entrada
var assetInput = 'users/dh-conciani/collection7/c7-general-post';
var file_name = 'CERRADO_col7_native9_rocky3';

// Carregue a sua coleção aqui
var collection = ee.Image(assetInput + '/' + file_name);

// Defina seu asset de saída
var assetOutput = 'projects/mapbiomas-workspace/COLECAO7/classificacao';

// Defina a versão de saída
var outputVersion = '2';

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

        // remap 21 into UCs to 15
        imageYear = imageYear.where(imageYear.eq(21).and(pa.eq(1)), 15);
        // remap 12 into mask to 29
        imageYear = imageYear.where(imageYear.eq(12).and(geometry_mask.eq(1)), 29);
        
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
