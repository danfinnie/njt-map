require 'sqlite3'

require File.join(File.dirname(__FILE__), "njtmap.rb")

module NJTMap
	class Database < ::SQLite3::Database
		def find_service_ids_for_time(t)
			execute("select service_id from calendar_dates where date=?", t.to_s_gtfs).map(&:first)
		end
	end

	DB = Database.new("gtfs.db")
end
