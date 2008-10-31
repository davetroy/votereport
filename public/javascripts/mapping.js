var mapstraction, drawControls;
var last_updated = null;
var filters = "";

function initMap(map_filters){
    // initialise the map with your choice of API
    mapstraction = new Mapstraction('map','google');

    filters = map_filters;
    var myPoint = new LatLonPoint(50, -110);
    // display the map centered on a latitude and longitude (Google zoom levels)
    mapstraction.setCenterAndZoom(myPoint, 3);
    mapstraction.addControls({zoom: 'small'});
    mapstraction.addOverlay("/reports.kml?live=1&"+ filters);
    last_updated = new Date().toISO8601String();
    $("#last_updated").text(last_updated);
    setInterval("updateMap();",60000);

}
function remoteLoad(file, handler) {
	jsonp(file, handler);
}

function jsonp(url,callback, query)
{                
    if (url.indexOf("?") > -1)
        url += "&callback=" 
    else
        url += "?callback=" 
    url += callback + "&";
    if (query)
        url += encodeURIComponent(query) + "&";   
    url += new Date().getTime().toString(); // prevent caching        
    
    var script = document.createElement("script");        
    script.setAttribute("src",url);
    script.setAttribute("type","text/javascript");                
    document.body.appendChild(script);
}

function initMapJS(map_filters){
    // initialise the map with your choice of API
    mapstraction = new Mapstraction('map','google');
    filters = map_filters;

    var myPoint = new LatLonPoint(50, -110);
    // display the map centered on a latitude and longitude (Google zoom levels)
    mapstraction.setCenterAndZoom(myPoint, 3);
    mapstraction.addControls({zoom: 'small'});

    last_updated = new Date().toISO8601String();
    $("#last_updated").text(last_updated);
    // setInterval("updateMap();",60000);

}
function loadMarkers(response) {
    mapstraction.addJSON(response);
    mapstraction.autoCenterAndZoom();
    
}
function updateMap() {
    $("#update_status").show();
    mapstraction.addOverlay("http://votereport.us/reports.kml?dtstart="+last_updated + "&" + filters);
    last_updated = new Date().toISO8601String();
    $("#last_updated").text(last_updated);    
    $("#update_status").hide();
    return false;
}

Mapstraction.prototype.addJSON = function(features) {
// var features = eval('(' + json + ')');
var map = this.maps[this.api];
var html = "";
var polyline;
var item;
var asset_server = "http://assets0.mapufacture.com";
for (var i = 0; i < features.length; i++) {
	item = features[i].report;
	if(item.location.location.point != null) {

		switch(item.location.location.point.type) {
			case "Point":
			var icon_size; var icon;
			html = "<div class='balloon'><strong>" + item.zip + "</strong><p>" + item.text + "</p></div>";
			if(item.icon == "" || item.icon == null){
				icon = "/images/gmaps/pushpins/webhues/159.png" 
				icon_size = [10,17];
				
			} else {
				icon = item.icon;
				icon_size = [32,32];
			}
			
			this.addMarkerWithData(new Marker(new LatLonPoint(item.location.location.point.coordinates[1],item.location.location.point.coordinates[0])),{
				infoBubble : html, 
				label : item.name, 
				date : "new Date(\""+item.date+"\")", 
				iconShadow : item.icon_shadow,
				marker : item.id, 
				date : "new Date(\""+item.date+"\")", 
				iconShadowSize : item.icon_shadow_size,
				icon : icon,
				iconSize : icon_size, 
				category : item.source_id, 
				draggable : false, 
				hover : false});

				break;
			case "Polygon":
				var points = [];
				polyline = new Polyline(points);
				this.addPolylineWithData(polyline,{fillColor : item.poly_color,date : "new Date(\""+item.date+"\")",category : item.source_id,width : item.line_width,opacity : item.line_opacity,color : item.line_color, polygon : true});					
				default:
				// console.log("Geometry: " + features.items[i].geometry.type);
			}
		}
	}
}


