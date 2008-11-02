var mapstraction, drawControls;
var last_updated = null;
var filters = "";
var state = ""; // used for autoZoom toggling

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
function loadJSON(file, handler) {
	req = new XMLHttpRequest();
	req.open("GET", file, true); 
	req.onreadystatechange = handler;   // the handler 
	req.send(null); 
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

    // display the map centered on a latitude and longitude (Google zoom levels)
    var myPoint = new LatLonPoint(38, -90);
    mapstraction.setCenterAndZoom(myPoint, 4);
    mapstraction.addControls({zoom: 'small'});
    
    last_updated = new Date().toISO8601String();
    $("#last_updated").text(last_updated);
    // setInterval("updateMap();",60000);

}
function loadMarkers(response) {
    mapstraction.addJSON(response);
    if(state != "")
        mapstraction.autoCenterAndZoom();
    
}
function updateMap(map_filter) {
    var current_filter = "";
    if(map_filter != "" || map_filter != null) {
        mapstraction.removeAllMarkers();
        gmarkers = [];
        filters = current_filter = map_filter;
    } else {
        current_filter = "dtstart="+last_updated+"&" + filters;
    }
        
    $("#update_status").show();
    $.getJSON("/reports.json?"+current_filter, updateJSON);
    return false;
}
function updateJSON(response) {
    mapstraction.addJSON(response);
    last_updated = new Date().toISO8601String();
    $("#last_updated").text(last_updated);    
    $("#update_status").hide();
}

var gmarkers = []
Mapstraction.prototype.addJSON = function(features) {
// var features = eval('(' + json + ')');
var map = this.maps[this.api];
var html = "";
var polyline;
var item;
var asset_server = "http://assets0.mapufacture.com";

for (var i = 0; i < features.length; i++) {
	item = features[i].report;
	if(item.location != null && item.location.location.point != null) {

		switch(item.location.location.point.type) {
			case "Point":
			var icon_size; var icon;
            if(item.rating != null) {
                if(item.rating <= 30)
                    icon = "/images/rating_bad.png"
                else if (item.rating <= 70)
                    icon = "/images/rating_medium.png"
                else
                    icon = "/images/rating_good.png"
            }
			else if(item.icon == "" || item.icon == null){
				icon = "/images/gmaps/pushpins/webhues/159.png" 
				icon_size = [10,17];
				
			} else {
                icon = "/images/rating_none.png"
                // icon = item.icon;
			}
            icon_size = [16,16];

            html = "<div class='balloon'><strong><img src='" + item.icon + "'>" + item.name + "</strong><br />" + item.display_text + "<br />";
            if(item.rating != null)
                html += "Rating: <img src='"+icon+"'/> ("+item.rating+"%)";
			html += "</div>";
			
			this.addMarkerWithData(new Marker(new LatLonPoint(item.location.location.point.coordinates[1],item.location.location.point.coordinates[0])),{
				infoBubble : html, 
				label : item.name, 
				date : "new Date(\""+item.created_at+"\")", 
				iconShadow : "http://mapufacture.com/images/providers/blank.png",
				marker : item.id, 
				date : "new Date(\""+item.date+"\")", 
				iconShadowSize : [0,0],
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

