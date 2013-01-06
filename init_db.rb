#! /usr/bin/env ruby19

require 'sqlite3'
require 'csv'

def open_bus_and_rail(filename, &blk)
	process_csv = proc { |id_mask, f|
		c = CSV.new(f, headers: true, return_headers: false)
		p id_mask
		post_process = if id_mask.zero?
					proc { |x| x }
				else
					proc { |data, id_col| 
						data.zip(id_col).map do |d, mask|
							begin
								mask ? Integer(d) | id_mask : d
							rescue ArgumentError, TypeError
								d
							end
						end
					}
				end
		c.each do |row|
			inc_insert_count()
			values = Array.new(row.length) { |i| row[i] }
			blk.call(post_process, values)
		end
	}.curry

	File.open("bus_data/#{filename}.txt", "r:UTF-8", &process_csv[0]) 
	File.open("rail_data/#{filename}.txt", "r:UTF-8", &process_csv[1 << 31])
end

def inc_insert_count
	$insert_count += 1
 	if $insert_count % 1000 == 0
		puts "#{$insert_count} rows inserted"
	end
end

db = SQLite3::Database.new("gtfs.db")
$insert_count = 0

# Prepared statements, indexed by table name, for inserting fields.
prepared_statements = {}

# Indexed by table name, shows which fields in that table represent IDs.  These fields should be incremented by id_mod.
id_cols = {}

# Populate above variables
File.readlines("schema.sql").each do |sql|
	name = sql[/table\W*(.*?)\(/, 1].intern

	id_col = sql.gsub(/,\W*primary key.*/, '').split(',').map {|y| !!(y =~ /[\W_]id/) }
	id_cols[name] = id_col

	placeholders = Array.new(id_col.size, "?").join(",")
	prepared_statements[name] = db.prepare("insert into #{name} values (#{placeholders})")
end

%w[routes trips calendar_dates shapes stops].each do |filename|
	stmt = prepared_statements[filename.intern]
	id_col = id_cols[filename.intern]
	open_bus_and_rail(filename) do |post_process, row|
		begin
			stmt.execute(*post_process.call(row, id_col))
		rescue SQLite3::Exception
			$stderr.puts "Current table: #{filename}"
			$stderr.puts "id_col: #{id_col.inspect}"
			$stderr.puts "row: #{row.inspect}"
			raise $!
		end
	end
end

stmt = prepared_statements[:stop_times]
id_col = id_cols[:stop_times]
open_bus_and_rail("stop_times") do |post_process, values|
	# Convert string times to seconds.
	(1..2).each do |i|
		values[i] = values[i].split(":").inject(0) { |memo, this| memo*60 + this.to_i }
	end

	begin
		stmt.execute(*post_process[values, id_col])
	rescue SQLite3::Exception
		$stderr.puts "Current table: stop_times"
		$stderr.puts "id_col: #{id_col.inspect}"
		$stderr.puts "row: #{values.inspect}"
		raise $!
	end
end
