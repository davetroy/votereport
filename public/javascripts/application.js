var map, drawControls;

function initMap(){
    map = new OpenLayers.Map('map', {maxResolution: 360/512,  controls: []});
    var wms = new OpenLayers.Layer.WMS( "OpenLayers WMS", 
        "http://labs.metacarta.com/wms-c/Basic.py", {'layers':'basic'}); 
    var wms2 = new OpenLayers.Layer.WMS( "OpenLayers WMS", 
        "http://labs.metacarta.com/wms-c/Basic.py", {'layers':'satellite'}); 
    map.addLayers([wms, wms2]);

	// map = new OpenLayers.Map(
	// 	"map",
	// 	{
	// 		maxExtent: new OpenLayers.Bounds(-20037508.34,-20037508.34,20037508.34,20037508.34),
	// 		maxResolution:156543, numZoomLevels:18, units:'meters', projection: "EPSG:41001"
	// 	}
	// );
	// 
	// var osmmapnik_layer = new OpenLayers.Layer.TMS(
	// 	'OSM Mapnik',
	// 	[
	// 			"http://a.tile.openstreetmap.org/",
	// 			"http://b.tile.openstreetmap.org/",
	// 			"http://c.tile.openstreetmap.org/"
	// 	],
	// 	{
	// 		type:'png',
	// 		getURL: function (bounds) {
	// 			var res = this.map.getResolution();
	// 			var x = Math.round ((bounds.left - this.maxExtent.left) / (res * this.tileSize.w));
	// 			var y = Math.round ((this.maxExtent.top - bounds.top) / (res * this.tileSize.h));
	// 			var z = this.map.getZoom();
	// 			var limit = Math.pow(2, z);
	// 			if (y < 0 || y >= limit) {
	// 				return null;
	// 			} else {
	// 				x = ((x % limit) + limit) % limit;
	// 				var path = z + "/" + x + "/" + y + "." + this.type;
	// 				var url = this.url;
	// 				if (url instanceof Array) {
	// 					url = this.selectUrl(path, url);
	// 				}
	// 				return url + path;
	// 			}
	// 		},
	// 		displayOutsideMaxExtent: true
	// 	}
	// );
	// 
	// var osm_layer = new OpenLayers.Layer.TMS(
	// 	'OSM',
	// 	[
	// 			"http://a.tah.openstreetmap.org/Tiles/tile.php/",
	// 			"http://b.tah.openstreetmap.org/Tiles/tile.php/",
	// 			"http://c.tah.openstreetmap.org/Tiles/tile.php/"
	// 	],
	// 	{
	// 		type:'png',
	// 		getURL: function (bounds) {
	// 			var res = this.map.getResolution();
	// 			var x = Math.round ((bounds.left - this.maxExtent.left) / (res * this.tileSize.w));
	// 			var y = Math.round ((this.maxExtent.top - bounds.top) / (res * this.tileSize.h));
	// 			var z = this.map.getZoom();
	// 			var limit = Math.pow(2, z);
	// 			if (y < 0 || y >= limit) {
	// 				return null;
	// 			} else {
	// 				x = ((x % limit) + limit) % limit;
	// 				var path = z + "/" + x + "/" + y + "." + this.type;
	// 				var url = this.url;
	// 				if (url instanceof Array) {
	// 					url = this.selectUrl(path, url);
	// 				}
	// 				return url + path;
	// 			}
	// 		},
	// 		displayOutsideMaxExtent: true
	// 	}
	// );
	// 
	// map.addLayers([osmmapnik_layer, osm_layer]);
    map.addControl(new OpenLayers.Control.Navigation());
    map.addControl(new OpenLayers.Control.MousePosition());
    map.addControl(new OpenLayers.Control.Permalink());
    map.addControl(new OpenLayers.Control.LayerSwitcher());
             	
    map.addLayer(new OpenLayers.Layer.GML("KML", "/reports.kml?live=1", 
       {
        format: OpenLayers.Format.KML, 
        formatOptions: {
          extractStyles: true, 
          extractAttributes: true
        }
       }));
	map.zoomToExtent(new OpenLayers.Bounds(-120,30,-80,60));
}
