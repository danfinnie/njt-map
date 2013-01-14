create table calendar_dates(service_id integer, date integer, exception_type integer, primary key (service_id, date));
create table routes(route_id integer, agency_id integer, route_short_name text, route_long_name text, route_type integer, route_url text, route_color text, primary key (route_id));
create table shapes(shape_id integer, shape_pt_lat text, shape_pt_lon text, shape_pt_sequence integer, shape_dist_traveled real, start_relevancy real, end_relevancy real, primary key (shape_id, shape_pt_sequence));
create table stop_times(trip_id integer, arrival_time integer, departure_time integer, stop_id integer, stop_sequence integer, pickup_type integer, drop_off_type integer, shape_dist_traveled real, primary key (trip_id, stop_sequence));
create table stops(stop_id integer, stop_code integer, stop_name text, stop_desc text, stop_lat text, stop_lon text, zone_id integer, primary key (stop_id));
create table trips(route_id integer, service_id integer, trip_id integer, trip_headsign text, direction_id integer, block_id integer, shape_id integer, primary key (trip_id));
