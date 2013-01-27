function initialize() {
var mapOptions = {
  center: new google.maps.LatLng(40.171877413034224, -74.71853198262102),
  zoom: 10,
  mapTypeId: google.maps.MapTypeId.ROADMAP
};

var map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
var currentMarkers = [];
// var nextMarkers = {}

dataGatherer = window.setInterval(function() {
  var cacheBuster = Math.floor(Math.random()*10000) + "";
  $.get("data.json", cacheBuster, function(data, textStatus, jqXhr) {
    nextMarkers = [];
    $.each(data.locs, function() {
      marker = new google.maps.Marker({
        position: new google.maps.LatLng(this.lat, this.lon),
        title: this.trip + " btwn " + this.from + " and " + this.to
      });
      marker.setMap(map);
      nextMarkers.push(marker);
    });

    // Garbage collect old markers and remove them from the map
    // (they are no longer in existence)
    $.each(currentMarkers, function() {
      this.setMap(null);
    });
    
    currentMarkers = nextMarkers;
  }, "json");
}, 1000);
}
