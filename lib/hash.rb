require 'json'

require File.join(File.dirname(__FILE__), "njtmap.rb")

module NJTMap
	# Class to represent hash values.  Makes things pretty print to JSON!
	class Hash
		def initialize(hash)
			@hash = hash > 0 ? hash : hash.abs | 1 << 64
		end

		def to_json a
			@hash.to_s(32).downcase.to_json
		end
	end
end