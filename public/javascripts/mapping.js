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

// Adds a semi-opaque gray overlay on the map to make the markers pop out more
function fadeMap() {
    // mapstraction.getMap().addOverlay(new GPolygon([new GLatLng(-85,0),new GLatLng(85,0),new GLatLng(85,90),new GLatLng(-85,90)],null,0,0,"#BBBBBB",0.4));
    // mapstraction.getMap().addOverlay(new GPolygon([new GLatLng(-85,90),new GLatLng(85,90),new GLatLng(85,180),new GLatLng(-85,180)],null,0,0,"#BBBBBB",0.4));
    mapstraction.getMap().addOverlay(new GPolygon([new GLatLng(20,180.000001),new GLatLng(70,180.000001),new GLatLng(70,330),new GLatLng(-20,330)],null,0,0,"#d0d0d0",0.4));
    // mapstraction.getMap().addOverlay(new GPolygon([new GLatLng(-85,270),new GLatLng(85,270),new GLatLng(85,360),new GLatLng(-85,360)],null,0,0,"#BBBBBB",0.4));

}
function initMapJS(map_filters){
    // initialise the map with your choice of API
    mapstraction = new Mapstraction('map','google');
    filters = map_filters;

    $("#filter_state").change(function () { 
        state = $("#filter_state").val();
        updateState(state);
    });
    // display the map centered on a latitude and longitude (Google zoom levels)
    var myPoint = new LatLonPoint(38, -100);
    mapstraction.setCenterAndZoom(myPoint, 4);
    mapstraction.addControls({zoom: 'small'});

    fadeMap();
    last_updated = new Date().toISO8601String();
    $("#last_updated").text(last_updated);
    // setInterval("updateMap();",60000);

}
var current_page = 1;
function updateState(state, page) {
    var current_filter = "";
    if(page == null)
        page = 1;
    else {
        $("#page_" + current_page).removeClass("current");
        $("#page_" + page).addClass("current");        
    }

    hideMessage();
    current_page = page;
    mapstraction.removeAllMarkers();
    fadeMap();
    gmarkers = [];
    filters = current_filter = "state=" + state;
        
    $("#update_status").show();
    if(state == null)
        $.getJSON("/feeds/" + page +".json", "");    
    else
        $.getJSON("/feeds/state/"+state+"/" + page +".json", "");
    return false;
}
function updateMap(map_filter) {
    var current_filter = "";
    hideMessage();

    if(map_filter != "" || map_filter != null) {
        mapstraction.removeAllMarkers();
        fadeMap();
        gmarkers = [];
        filters = current_filter = map_filter;
    } else {
        current_filter = "dtstart="+last_updated+"&" + filters;
    }
        
    $("#update_status").show();
    $.getJSON("/reports.json?"+current_filter+"&page=1&count=200&callback=updateJSON", "");
    return false;
}
function showMessage(message) {
    $("#message").text(message);
    $("#message").show();
}
function hideMessage(message) {
    $("#message").text("");
    $("#message").hide();
}
function updateJSON(response) {
    var num_markers = mapstraction.addJSON(response);
    if(num_markers <= 0)
        showMessage("Sorry - no reports with this filter.");
    else if(state != "")
        mapstraction.autoCenterAndZoom();
    
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
var num_markers = 0;
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
			icon_scale = 0.18 * item.wait_time + 10;
			if(icon_scale > 24)
			    icon_scale = 24
            icon_size = [icon_scale,icon_scale];

            // html = "<div class='balloon'><strong><img src='" + item.icon + "'>" + item.name + "</strong><br />" + item.display_text + "<br />";
            html = item.display_html;

            //             if(item.rating != null)
            //                 html += "Rating: <img src='"+icon+"'/> ("+item.rating+"%)";
            //             if(item.rating != null)
            //                 html += "<br />Wait time: "+ item.wait_time+" min";
            //             if(item.location.location.address != null)
            //                 html += "<br />Location: "+ item.location.location.address+" min";
            // 
            // html += "</div>";
			
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
			num_markers += 1;
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
    return num_markers;
}

