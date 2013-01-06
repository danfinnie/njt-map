require File.join(File.dirname(__FILE__), "database.rb")

# A VehiclePosition represents the progress of a vehicle between 2 stops.
# In terms of GTFS data, it is the combination of a stop_time with the stop_time of the same trip ID
# and a one higher stop_sequence.
module NJTMap
	class VehiclePosition
		@@stmt = DB.prepare("
			select *
			from stop_times first_stop
			join stop_times second_stop on (
			  first_stop.stop_sequence+1=second_stop.stop_sequence
			  and first_stop.trip_id = second_stop.trip_id
			)
			where first_stop.trip_id in (select trip_id from trips where service_id=:service_id)
			and first_stop.departure_time < :time 
			and second_stop.departure_time > :time;
		");

		def self.for_service_and_time(service_id, time)
			@@stmt.execute(service_id: service_id, time: time).map(&method(:new))
		end

		@x = :undef
		def initialize(x)
			@x = x
		end
	end
end