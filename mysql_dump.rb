#! /usr/bin/env ruby19

while gets
	case $_
	when /^INSERT/i
		print $_.sub('"', '`').sub('"', '`') # Quote around column names.
	when /^CREATE/
		print $_.gsub(/int(eger?)/i, "bigint")
	when /^(PRAGMA|BEGIN|COMMIT)/i
		# drop these lines
	else
		print $_
	end
end
