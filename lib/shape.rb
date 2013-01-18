require File.join(File.dirname(__FILE__), "njtmap.rb")
require File.join(File.dirname(__FILE__), "location.rb")

module NJTMap
	class Shape < Location
		def initialize(shape_id, shape_pt_lat, shape_pt_lon, shape_pt_sequence, shape_dist_traveled, *args) # *args is a quick patch until new schema is fully utilized
			@shape_id, @shape_pt_lat, @shape_pt_lon, @shape_pt_sequence, @shape_dist_traveled = shape_id, shape_pt_lat.to_f, shape_pt_lon.to_f, shape_pt_sequence, shape_dist_traveled
		end

		attr_reader :shape_id, :shape_pt_lat, :shape_pt_lon, :shape_pt_sequence, :shape_dist_traveled

		def x
			shape_pt_lon
		end

		def y
			shape_pt_lat
		end
	end
end