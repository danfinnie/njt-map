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
	end
end