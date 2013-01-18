module NJTMap
	# Abstract class that represents a spot on a 2D plane
	class Location
		def initialize x, y
			@x, @y = x, y
		end

		attr_reader :x, :y

		# Return a Location representing a point in between this point and 'o'.
		# fraction_complete is a number between 0 and 1, inclusive, representing
		# the percentage of distance travaled from this to o.
		def find_intermediary(o, fraction_complete)
			return self if fraction_complete == 1 || self == o

			m = (o.y - self.y) / (o.x - self.x)
			new_x = new_y = (0/0.0) # NaN

			delta_y = (y - o.y).abs
			delta_x = (x - o.x).abs

			if m.infinite? # Vertical line and o == self
				new_x = x
				new_y = y + (o.y - y) * fraction_complete
			else
				new_x = x + (o.x - x) * fraction_complete
				new_y = m * (new_x - x) + y
			end

			Location.new(new_x, new_y)
		end

		def inspect
			"<Location #{y}, #{x}>"
		end
	end
end