module NJTMap
	class DateOutOfRangeError < ArgumentError
		def initialize(str="The date requested does not have information in the GTFS file provided")
			super(str)
		end
	end
end