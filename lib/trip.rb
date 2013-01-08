require File.join(File.dirname(__FILE__), "njtmap.rb")

module NJTMap
	class Trip
		def initialize(route_id, service_id, trip_id, trip_headsign, direction_id, block_id, shape_id)
			@route_id, @service_id, @trip_id, @trip_headsign, @direction_id, @block_id, @shape_id = route_id, service_id, trip_id, trip_headsign, direction_id, block_id, shape_id
		end

		attr_reader :route_id, :service_id, :trip_id, :trip_headsign, :direction_id, :block_id, :shape_id
	end
end