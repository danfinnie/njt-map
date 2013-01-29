<?php

error_reporting(E_ALL);
ini_set('display_errors', 1);

include("config.php.inc");
header("Content-type: application/json");

$dbh = new PDO('mysql:host=localhost;dbname='.$config['db-name'], $config['db-user'], $config['db-password']);

$now = new DateTime();
$date = $now->format("Ymd");

$now->setTime(12, 0);
$seconds_into_day = time() - ($now->getTimestamp() - 12*60*60);

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

echo "{\"locs\": [";
$delim = '';

while($row = $stmt->fetch(PDO::FETCH_NUM)) {
	// JSON outputting
	echo $delim;
	$delim = ',';

	$trip_id = $row[0];
    $shape_id = $row[1];
    $first_dept_time = $row[2];
    $second_dept_time = $row[3];
    $first_dist_traveled = $row[4];
    $second_dist_traveled = $row[5];

    $fraction_complete = ($seconds_into_day - $first_dept_time) * 1.0 / ($second_dept_time - $first_dept_time);
    $dist_traveled = $fraction_complete * ($second_dist_traveled - $first_dist_traveled) + $first_dist_traveled;

    //$pos = calc_lat_lon($shape_id, $dist_traveled);
    $pos = array("lat" => 42, "lon" => 45.3);

    echo json_encode(array(
    	"trip_id" => $trip_id,
    	"lat" => $pos['lat'],
    	"lon" => $pos['lon'],
    ));
}

echo ']}';
