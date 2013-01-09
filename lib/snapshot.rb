require File.join(File.dirname(__FILE__), "njtmap.rb")
require File.join(File.dirname(__FILE__), "time.rb")
require File.join(File.dirname(__FILE__), "database.rb")
require File.join(File.dirname(__FILE__), "vehicle_position.rb")

# A Snapshot represents an instance in time and that time's current transit positions.
module NJTMap
	class Snapshot
		def initialize(date)
			@date = Time.from_time(date)
			@seconds_into_day = @date.seconds_into_day
			
			unless @service_ids = DB.find_service_ids_for_time(@date)
				throw DateOutOfRangeError.new
			end

			Log.info { inspect }
		end

		def positions
			VehiclePosition.for_services_and_time(@service_ids, @seconds_into_day)
		end

		attr_reader :seconds_into_day
	end
end