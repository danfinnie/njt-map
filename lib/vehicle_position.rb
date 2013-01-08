require 'arrayfields'

require File.join(File.dirname(__FILE__), "njtmap.rb")
require File.join(File.dirname(__FILE__), "database.rb")

# A VehiclePosition represents the progress of a vehicle between 2 stops.
# In terms of GTFS data, it is the combination of a stop_time with the stop_time of the same trip ID
# and a one higher stop_sequence.
module NJTMap
	class VehiclePosition
		@@stmt = 

		def self.for_services_and_time(service_ids, time)
			resp = DB.execute2("
				select *
				from stop_times first_stop
				join stop_times second_stop on (
				  first_stop.stop_sequence+1=second_stop.stop_sequence
				  and first_stop.trip_id = second_stop.trip_id
				)
				where first_stop.trip_id in (select trip_id from trips where service_id in (#{service_ids.join(',')}))
				and first_stop.departure_time < :time 
				and second_stop.departure_time > :time
			;", time: time)

			fields = resp.shift.map(&:intern)
			resp.map { |row| new(fields, row) }
		end

		def initialize(fields, row)
			split = row.size/2
			@first_stop = row[0...split]
			@second_stop = row[split..-1]

			@first_stop.fields = fields[0...split]
			@second_stop.fields = fields[0...split]
		end

		def inspect
			"#<#{self.class}:0x#{object_id.to_s(16)} #{trip_name.inspect} btwn #{first_stop_name.inspect} and #{second_stop_name.inspect}>"
		end

		private
		def trip_name
			DB.get_first_value("select trip_headsign from trips where trip_id=?", @first_stop[:trip_id])
		end

		def first_stop_name
			DB.get_first_value("select stop_name from stops where stop_id=?", @first_stop[:stop_id])
		end

		def second_stop_name
			DB.get_first_value("select stop_name from stops where stop_id=?", @second_stop[:stop_id])
		end
	end
end