require File.join(File.dirname(__FILE__), "njtmap.rb")

module NJTMap
	class StopTime
		def initialize(trip_id, arrival_time, departure_time, stop_id, stop_sequence, pickup_type, drop_off_type, shape_dist_traveled)
			@trip_id, @arrival_time, @departure_time, @stop_id, @stop_sequence, @pickup_type, @drop_off_type, @shape_dist_traveled = trip_id, arrival_time, departure_time, stop_id, stop_sequence, pickup_type, drop_off_type, shape_dist_traveled
		end

		attr_reader :trip_id, :arrival_time, :departure_time, :stop_id, :stop_sequence, :pickup_type, :drop_off_type, :shape_dist_traveled
	end
end