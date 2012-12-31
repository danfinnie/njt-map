# A Snapshot represents an instance in time and that time's current transit positions.
module NJTMap
	class Snapshot
		def initialize(date)
			@date = date
		end

		def positions
			[@date.to_s] * 3
		end
	end
end