module NJTMap
	attr_accessor :logger

	class DateOutOfRangeError < ArgumentError
		def initialize(str="The date requested does not have information in the GTFS file provided")
			super(str)
		end
	end
end