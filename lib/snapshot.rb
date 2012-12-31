require File.join(File.dirname(__FILE__), "time.rb")
require File.join(File.dirname(__FILE__), "database.rb")
require File.join(File.dirname(__FILE__), "exceptions.rb")



# A Snapshot represents an instance in time and that time's current transit positions.
module NJTMap
	class Snapshot
		def initialize(date)
			@date = Time.from_time(date)
			
			unless @service_id = DB.find_service_id_for_time(@date)
				throw DateOutOfRangeError.new
			end
		end

		def positions
			[@date, @service_id]
		end

		private
	end
end