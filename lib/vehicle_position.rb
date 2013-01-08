require 'arrayfields'

require File.join(File.dirname(__FILE__), "njtmap.rb")
require File.join(File.dirname(__FILE__), "database.rb")

require File.join(File.dirname(__FILE__), "stop.rb")
require File.join(File.dirname(__FILE__), "trip.rb")
require File.join(File.dirname(__FILE__), "stop_time.rb")

# A VehiclePosition represents the progress of a vehicle between 2 stops.
# In terms of GTFS data, it is the combination of a stop_time with the stop_time of the same trip ID
# and a one higher stop_sequence.
module NJTMap
	class VehiclePosition
		ORM = [
			[StopTime, :@first_stop_time],
			[StopTime, :@second_stop_time],
			[Stop, :@first_stop],
			[Stop, :@second_stop],
			[Trip, :@trip],
		]

		def self.for_services_and_time(service_ids, time)
			resp = DB.execute("
				select *
				from stop_times first_stop
				join stop_times second_stop on (
				  first_stop.stop_sequence+1=second_stop.stop_sequence
				  and first_stop.trip_id = second_stop.trip_id
				)
				join stops first_stop_info on first_stop_info.stop_id = first_stop.stop_id
				join stops second_stop_info on second_stop_info.stop_id = second_stop.stop_id
				join trips on trips.trip_id = first_stop.trip_id
				where first_stop.trip_id in (select trip_id from trips where service_id in (#{service_ids.join(',')}))
				and first_stop.departure_time < :time 
				and second_stop.departure_time > :time
			;", time: time)

			resp.map { |row| new(row) }
		end

		def initialize(row)
			ORM.each do |klass, instance_var|
				arity = klass.instance_method(:initialize).arity
				raise new Exception("Classes instantiated by ORM must be of constant arity") if arity <= 0
				instance = klass.new(*row.shift(arity))
				instance_variable_set(instance_var, instance)
			end
		end

		def inspect
			"#<#{self.class}:0x#{object_id.to_s(16)} #{@trip.trip_headsign} btwn #{@first_stop.stop_name } and #{@second_stop.stop_name}>"
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