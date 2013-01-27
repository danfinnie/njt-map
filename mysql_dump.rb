#! /usr/bin/env ruby19

while gets
	case $_
	when /^(PRAGMA|BEGIN|COMMIT|ANALYZE|INSERT.*sqlite_stat)/i
		# drop these lines
	when /^INSERT/i
		print $_.sub('"', '`').sub('"', '`') # Quote around column names.
	when /^CREATE/
		print $_.gsub(/int(eger?)/i, "bigint")
	else
		print $_
	end
end
