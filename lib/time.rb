require File.join(File.dirname(__FILE__), "njtmap.rb")

module NJTMap
	class Time < ::Time
		def self.from_time o
			at(o.tv_sec)
		end

		def inspect
			"#<NJTMap::Time #{super}>"
		end

		# Return the time in the YYYYMMDD format expected by the GTFS schema.
		def to_s_gtfs
			strftime('%Y%m%d')
		end

		def seconds_into_day
			day_start_noon = Time.new(year, month, day, 12, 0, 0, utc_offset)
			day_start_midnight = day_start_noon - 12*60*60
			(self - day_start_midnight).to_i
		end
	end
end