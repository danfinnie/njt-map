require File.join(File.dirname(__FILE__), "time.rb")

# A Snapshot represents an instance in time and that time's current transit positions.
module NJTMap
	class Snapshot
		def initialize(date)
			@date = Time.from_time(date)
		end

		def positions
			[@date] * 3
		end
	end
end