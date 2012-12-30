#! /usr/bin/env ruby19

require 'sqlite3'
require 'csv'

unless Dir.exist('bus_data') || Dir.exist('rail_data')
	puts "Please download and extract the bus_data.zip and rail_data.zip files from the NJ Transit Developers site."
	exit 1
end

