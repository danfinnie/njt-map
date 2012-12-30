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

open_bus_and_rail("agency") do |r|
	p r
end