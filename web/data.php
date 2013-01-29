<?php

include("config.php.inc");
header("Content-type: application/json");

$file = null;

class ShapePt {
	public $lat, $lon, $dist_traveled;

	function __construct($lat, $lon, $dist_traveled) {
		$this->lat = $lat;
		$this->lon = $lon;
		$this->dist_traveled = $dist_traveled;
	}
}

// Output a string to all relevant output buffers.
function output($str) {
	global $file;

	echo $str;
	if (!is_null($file)) {
		fwrite($file, $str);
	}
}

// Returns an array with keys lat and lon.
function find_intermediary($prev_shape, $next_shape, $fraction_complete) {
	if ($fraction_complete == 1 || ($prev_shape->lat == $next_shape->lat && $prev_shape->lon == $next_shape->lon)) {
		return array(
			"lat" => $prev_shape->lat,
			"lon" => $prev_shape->lon,
		);
	}

	$delta_y = abs($prev_shape->lat - $next_shape->lat);
    $delta_x = abs($prev_shape->lon - $prev_shape->lon);
    $m = @(($next_shape->lat - $prev_shape->lat) * 1.0 / ($next_shape->lon - $prev_shape->lon));

    $lon = null;
    $lat = null;
    if (is_nan($m) || is_infinite($m)) {
        $lon = $prev_shape->lon;
        $lat = $prev_shape->lat + ($next_shape->lat - $prev_shape->lat) * $fraction_complete;
    } else {
        $lon = $prev_shape->lon + ($next_shape->lon - $prev_shape->lon) * $fraction_complete;
        $lat = $m * ($lon - $prev_shape->lon) + $prev_shape->lat;
    }

    return array(
    	"lat" => $lat,
    	"lon" => $lon,
    );
}

// Returns an array with keys lat and lon.
function calc_lat_lon($dbh, $shape_id, $dist_traveled) {
	static $stmt = null;
	$fraction_complete;
	$next_shape;

	if ($stmt == null) {
		$stmt = $dbh->prepare("
			select shape_pt_lat, shape_pt_lon, shape_dist_traveled
            from shapes
            where shape_id = :shape_id
            and (start_relevancy < :dist_traveled or start_relevancy = 0)
            and end_relevancy >= :dist_traveled 
            order by shape_pt_sequence desc
            limit 2
        ");
	}

	$stmt->bindValue("shape_id", $shape_id);
	$stmt->bindValue("dist_traveled", $dist_traveled);
	$stmt->execute();

	$row = $stmt->fetch(PDO::FETCH_NUM);
	$prev_shape = new ShapePt($row[0], $row[1], $row[2]);

	if ($row = $stmt->fetch(PDO::FETCH_NUM)) {
		$next_shape = new ShapePt($row[0], $row[1], $row[2]);
		$fraction_complete = ($dist_traveled - $prev_shape->dist_traveled) / ($next_shape->dist_traveled - $prev_shape->dist_traveled);
	} else {
		$next_shape = $prev_shape;
		$fraction_complete = 1;
	}

	$stmt->closeCursor();
	return find_intermediary($prev_shape, $next_shape, $fraction_complete);
}

$now = new DateTime();
$date = $now->format("Ymd");

$now->setTime(12, 0);
$seconds_into_day = time() - ($now->format("U") - 12*60*60);

// Check for relevant cached results.
if ($config['cache-file']) {
	$cacheStr = file_get_contents($config['cache-file']);
	$cacheJson = json_decode($cacheStr, true);
	if ($cacheJson['date'] == $date && $cacheJson['seconds_into_day'] + $config['cache-duration'] > $seconds_into_day && $cacheJson['seconds_into_day'] - $config['cache-duration'] <  $seconds_into_day) {
		// Cache hit.
		echo file_get_contents($config['cache-file']);
		exit(0);
	}

	// Cache miss
	$file = fopen($config['cache-file'], 'w');
}

$dbh = new PDO('mysql:host=localhost;dbname='.$config['db-name'], $config['db-user'], $config['db-password']);

$stmt = $dbh->prepare("
	SELECT trips.trip_id, trips.shape_id, first_stop.departure_time, second_stop.departure_time, first_stop.shape_dist_traveled, second_stop.shape_dist_traveled
	FROM stop_times first_stop
	JOIN stop_times second_stop ON ( first_stop.stop_sequence + 1 = second_stop.stop_sequence
	AND first_stop.trip_id = second_stop.trip_id )
	JOIN trips ON trips.trip_id = first_stop.trip_id
	JOIN stops first_stop_info ON first_stop_info.stop_id = first_stop.stop_id
	JOIN stops second_stop_info ON second_stop_info.stop_id = second_stop.stop_id
	WHERE trips.service_id in (select service_id from calendar_dates where date = :date)
    and first_stop.departure_time <= :time
    and second_stop.departure_time > :time");
$stmt->bindValue('date', $date);
$stmt->bindValue('time', $seconds_into_day, PDO::PARAM_INT);
$stmt->execute();

output("{\"date\":\"$date\",\"seconds_into_day\":$seconds_into_day,\"locs\": [");
$delim = '';

while($row = $stmt->fetch(PDO::FETCH_NUM)) {
	// JSON outputting
	output($delim);
	$delim = ',';

	$trip_id = $row[0];
    $shape_id = $row[1];
    $first_dept_time = $row[2];
    $second_dept_time = $row[3];
    $first_dist_traveled = $row[4];
    $second_dist_traveled = $row[5];

    $fraction_complete = ($seconds_into_day - $first_dept_time) * 1.0 / ($second_dept_time - $first_dept_time);
    $dist_traveled = $fraction_complete * ($second_dist_traveled - $first_dist_traveled) + $first_dist_traveled;

    $pos = calc_lat_lon($dbh, $shape_id, $dist_traveled);

    output(json_encode(array(
    	"trip_id" => $trip_id,
    	"lat" => $pos['lat'],
    	"lon" => $pos['lon'],
    )));
}

output(']}');

if (!is_null($file)) {
	fclose($file);
}
