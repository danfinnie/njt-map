require 'sqlite3'

require File.join(File.dirname(__FILE__), "njtmap.rb")

module NJTMap
	class Database < ::SQLite3::Database
		def find_service_ids_for_time(t)
			execute("select service_id from calendar_dates where date=?", t.to_s_gtfs).map(&:first)
		end

		def execute(sql, *bind_vars, &blk)
			Log.info do
				ret = "executing sql #{format_sql(sql).inspect}"
				ret += " with vars #{bind_vars.inspect}" if bind_vars.length > 0
				ret
			end
			super(sql, *bind_vars, &blk)
		end

		def prepare(sql)
			Log.info { "preparing sql #{format_sql(sql).inspect}" }
			super(sql)
		end

		private
		def format_sql(sql)
			sql.gsub(/\n\s*/, ' ').gsub(/\s{2,}/, ' ').strip
		end
	end

	DB = Database.new("gtfs.db")
end
