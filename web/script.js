initialize = (function() { 
  var map;

  $(function() {
    $("#collapse").on("click", function() {
      $("body").toggleClass("collapsed");
      window.setTimeout(function() {
        google.maps.event.trigger(map, "resize");
      }, 1000);
    });
  });

  return (function() {
    var mapOptions = {
      center: new google.maps.LatLng(40.171877413034224, -74.71853198262102),
      zoom: 10,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };

    map = new google.maps.Map(document.getElementById("map_canvas"), mapOptions);
    window.map = map;
    var currentMarkers = [];
    // var nextMarkers = {}

    dataGatherer = function() {
      $("body").addClass("loading");
      var cacheBuster = Math.floor(Math.random()*10000) + "";
      $.get("data.php", cacheBuster, function(data, textStatus, jqXhr) {
        nextMarkers = [];
        $.each(data.locs, function() {
          marker = new google.maps.Marker({
            position: new google.maps.LatLng(this.lat, this.lon),
            title: "Unknown trip" // this.trip + " btwn " + this.from + " and " + this.to
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

        // Queue up next iteration only after all processing has been done to avoid choking bandwidth/CPU.
        $("body").removeClass("loading");
        window.setTimeout(dataGatherer, 1000);
      }, "json");
    };
    dataGatherer();
  });
})();