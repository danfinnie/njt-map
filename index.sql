create index idx_stop_times on stop_times(trip_id, departure_time);
create index idx_trips on trips(service_id);
analyze;
