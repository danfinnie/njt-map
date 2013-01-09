What is this?
=============

This project uses GTFS data from NJ Transit to display the instantaneous locations of its trains and 
buses at any given time.  It will respect holidays, weekends, and all that jazz.

How do I use it?
================

1. Install Ruby 1.9 and the following gems:
    * sqlite3
    * json
1. Sign up for a NJ Transit developer account from [their developer site](https://www.njtransit.com/mt/mt_servlet.srv?hdnPageAction=MTDevLoginTo).  Download the rail and bus files they provide and unzip them into this directory.
1. Run `make`.  This will create the `gtfs.db` file that contains all of the information from the files you downloaded and print status updates along the way.  As of December 2012 there are 13 million rows to be inserted into the table, you can use this to gauge the script's progress -- it took almost 3 hours on my machine.

SQL Schema
==========

The schema used for the gtfs.db sqlite database is what you would expect given the layout of the CSV files in GTFS with the following exceptions:

* All latitudes and longitudes are stored as strings so that no precision is lost converting to IEEE floats.
* The agencies file is not imported.  We are only dealing with one agency (NJ Transit).  NJ Transit divides itself into 2 agencies, one for bus and one for rail, however this distinction is also made by the `route_type` field in the `routes.txt` file.
* Arrival and depature times in GTFS are stored in the format `hh:mm:ss` as time past noon minus 12 hours ([more info](https://developers.google.com/transit/gtfs/reference#stop_times_fields)).  For easier searching, we convert these values to an integer representing seconds from the same time.  So `13:05:20` becomes `13*60*60 + 5*60 + 20 = 47,120`.

Station Waiting Time
--------------------

In using the data, it became clear that the data's stop_times.txt file does not use arrival_time and depature_time as intended by the GTFS specification.  Instead, arrival_time is always equal to departure_time.  To represent a trip stop with a wait, the data has 2 subsequent stops at the same stop_id.  These rows in stop_time can be found by the following queries:

    select *
    from stop_times a, stop_times b
    where a.trip_id = b.trip_id
    and a.stop_sequence + 1 = b.stop_sequence
    and a.stop_id = b.stop_id
    order by a.trip_id;

Or:

    select *
    from stop_times
    where shape_dist_traveled = 0
    and stop_sequence > 1
    order by trip_id;

This data is not cleaned on import, instead the distance calculation code was designed to gracefully handle distances of 0.  
