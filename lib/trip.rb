require File.join(File.dirname(__FILE__), "njtmap.rb")
require File.join(File.dirname(__FILE__), "database.rb")
require File.join(File.dirname(__FILE__), "shape.rb")

module NJTMap
	class Trip
		def initialize(route_id, service_id, trip_id, trip_headsign, direction_id, block_id, shape_id)
			@route_id, @service_id, @trip_id, @trip_headsign, @direction_id, @block_id, @shape_id = route_id, service_id, trip_id, trip_headsign, direction_id, block_id, shape_id
		end

		attr_reader :route_id, :service_id, :trip_id, :trip_headsign, :direction_id, :block_id, :shape_id

		# Return the shape points before and after the passed dist_travelled
		@@polyline_for_distance_stmt = DB.prepare('
			select shape_id, shape_pt_lat, shape_pt_lon, shape_pt_sequence, shape_dist_traveled
			from shapes
			where shape_id = :shape_id
			and start_relevancy < :middle_dist_traveled
			and end_relevancy >= :middle_dist_traveled
			order by shape_pt_sequence desc
			limit 2;
		')
		def polyline_for_distance(dist_travelled)
			res = @@polyline_for_distance_stmt.execute!(shape_id: shape_id, middle_dist_traveled: dist_travelled)

			case res.length
			when 1
				next_shape = prev_shape = Shape.new(*res[0])
				fraction_complete = 1
			when 2
				prev_shape = Shape.new(*res[0])
				next_shape = Shape.new(*res[1])
				fraction_complete = (dist_travelled - prev_shape.shape_dist_traveled) / (next_shape.shape_dist_traveled - prev_shape.shape_dist_traveled)
			else
				raise "Could not find polyline for trip #{trip_id}.  Results from query:\n#{res.inspect}" unless res.length == 2
			end

			prev_shape.find_intermediary(next_shape, fraction_complete)
		end
	end
end