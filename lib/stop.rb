require File.join(File.dirname(__FILE__), "njtmap.rb")

module NJTMap
	class Stop
		def initialize(stop_id, stop_code, stop_name, stop_desc, stop_lat, stop_lon, zone_id)
			@stop_id, @stop_code, @stop_name, @stop_desc, @stop_lat, @stop_lon, @zone_id = stop_id, stop_code, stop_name, stop_desc, stop_lat, stop_lon, zone_id
		end

		attr_reader :stop_id, :stop_code, :stop_name, :stop_desc, :stop_lat, :stop_lon, :zone_id
	end
end