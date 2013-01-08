require 'logger'

module NJTMap
	Logger = ::Logger
	Log = Logger.new(STDERR)
	Log.level = ::Logger::FATAL;

	class << self
		def log_level= l
			Log.level = l
		end
	end

	class DateOutOfRangeError < ArgumentError
		def initialize(str="The date requested does not have information in the GTFS file provided")
			super(str)
		end
	end
end