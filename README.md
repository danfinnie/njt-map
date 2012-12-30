What is this?
=============

This project uses GTFS data from NJ Transit to display the instantaneous locations of its trains and 
buses at any given time.  It will respect holidays, weekends, and all that jazz.

How do I use it?
================

1. Install Ruby 1.9 and the Sqlite3 gem.
1. Sign up for a NJ Transit developer account from [their developer site](https://www.njtransit.com/mt/mt_servlet.srv?hdnPageAction=MTDevLoginTo).  Download the rail and bus files they provide and unzip them into this directory.
1. Run `make`.

SQL Schema
==========

The schema used for the gtfs.db sqlite database is what you would expect given the layout of the CSV files in GTFS with the following exceptions:

* All latitudes and longitudes are stored as strings so that no precision is lost converting to IEEE floats.
* The agencies file is not imported.  We are only dealing with one agency (NJ Transit).  NJ Transit divides itself into 2 agencies, one for bus and one for rail, however this distinction is also made by the `route_type` field in the `routes.txt` file.
* Arrival and depature times in GTFS are stored in the format `hh:mm:ss` as time past noon minus 12 hours ([more info](https://developers.google.com/transit/gtfs/reference#stop_times_fields)).  For easier searching, we convert these values to an integer representing seconds from the same time.  So `13:05:20` becomes `13*60*60 + 5*60 + 20 = 47,120`.