require 'sqlite3'

module NJTMap
	class Database < ::SQLite3::Database
		def find_service_id_for_time(t)
			get_first_value("select service_id from calendar_dates where date=?", t.to_s_gtfs)
		end
	end

	DB = Database.new("gtfs.db")
end
