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
			select *
			from shapes early_shape
			join shapes late_shape on late_shape.shape_pt_sequence = 1 + early_shape.shape_pt_sequence
			where early_shape.shape_id = :shape_id
			and late_shape.shape_id = :shape_id 
			and early_shape.shape_dist_traveled < :middle_dist_traveled
			order by shape_pt_sequence desc
			limit 1;
		')
		def polyline_for_distance(dist_travelled)
			res = @@polyline_for_distance_stmt.execute!(shape_id: shape_id, middle_dist_traveled: dist_travelled)
			raise "Could not find polyline for trip #{trip_id}." unless res.length == 1

			shapes = res[0]
			split = shapes.length/2
			prev_shape = Shape.new(*shapes[0...split])
			next_shape = Shape.new(*shapes[split..-1])

			fraction_complete = (dist_travelled - prev_shape.shape_dist_traveled) / (next_shape.shape_dist_traveled - prev_shape.shape_dist_traveled)
			prev_shape.find_intermediary(next_shape, fraction_complete)
		end
	end
end