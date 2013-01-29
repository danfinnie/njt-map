create table calendar_dates(service_id integer, date integer, primary key (service_id, date));
create table shapes(shape_id integer, shape_pt_lat text, shape_pt_lon text, shape_pt_sequence integer, shape_dist_traveled real, start_relevancy real, end_relevancy real, primary key (shape_id, shape_pt_sequence));
create table stop_times(trip_id integer, arrival_time integer, departure_time integer, stop_id integer, stop_sequence integer, shape_dist_traveled real, primary key (trip_id, stop_sequence));
create table stops(stop_id integer, stop_lat text, stop_lon text, primary key (stop_id));
create table trips(service_id integer, trip_id integer, shape_id integer, primary key (trip_id));
