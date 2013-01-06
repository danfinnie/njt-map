require 'arrayfields'
require File.join(File.dirname(__FILE__), "database.rb")

# A VehiclePosition represents the progress of a vehicle between 2 stops.
# In terms of GTFS data, it is the combination of a stop_time with the stop_time of the same trip ID
# and a one higher stop_sequence.
module NJTMap
	class VehiclePosition
		@@stmt = DB.prepare("
			select *
			from stop_times first_stop
			join stop_times second_stop on (
			  first_stop.stop_sequence+1=second_stop.stop_sequence
			  and first_stop.trip_id = second_stop.trip_id
			)
			where first_stop.trip_id in (select trip_id from trips where service_id=:service_id)
			and first_stop.departure_time < :time 
			and second_stop.departure_time > :time;
		");
		@@fields = @@stmt.columns[0...(@@stmt.columns.length/2)]

		def self.for_service_and_time(service_id, time)
			@@stmt.execute(service_id: service_id, time: time).map(&method(:new))
		end

		def initialize(x)
			split = x.size/2
			@first_stop = x[0...split]
			@second_stop = x[split..-1]

			@first_stop.fields = @@fields
			@second_stop.fields = @@fields

			# @first_stop = @first_stop.to_h
			# @second_stop = @second_stop.to_h
		end
	end
end