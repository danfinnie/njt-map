#! /usr/bin/env ruby19

require 'sqlite3'
require 'csv'

def open_bus_and_rail(filename, &blk)
	process_csv = proc do |f|
		c = CSV.new(f, headers: true, return_headers: false)
		c.each(&blk)
	end

	File.open("bus_data/#{filename}.txt", "r:UTF-8", &process_csv) 
	File.open("rail_data/#{filename}.txt", "r:UTF-8", &process_csv)
end

def inc_insert_count
	$insert_count += 1
 	if $insert_count % 1000 == 0
		puts "#{$insert_count} rows inserted"
	end
end

db = SQLite3::Database.new("gtfs.db")
$insert_count = 0

# Parse the schema file to create prepared statements to insert into all the tables.
prepared_statements = File.readlines("schema.sql").inject({}) do |memo, this|
	name = this[/table\W*(.*)\(/, 1]
	num_placeholders = this.count(",") + 1
	placeholders = Array.new(num_placeholders, "?").join(",")
	memo[name.intern] = db.prepare("insert into #{name} values (#{placeholders})")
	memo
end

%w[routes trips calendar_dates shapes stops].each do |filename|
	stmt = prepared_statements[filename.intern]
	open_bus_and_rail(filename) do |row|
		inc_insert_count()
		values = Array.new(row.length) { |i| row[i] }
		stmt.execute(*values)
	end
end

stmt = prepared_statements[:stop_times]
open_bus_and_rail("stop_times") do |row|
	values = Array.new(row.length) { |i| row[i] }

	# Convert string times to seconds.
	(1..2).each do |i|
		values[i] = values[i].split(":").inject(0) { |memo, this| memo*60 + this.to_i }
	end

	inc_insert_count()
	stmt.execute(*values)
end