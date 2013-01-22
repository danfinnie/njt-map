trap "rm -f web/data.json.new" EXIT

while :
do
	bin/njt_pos > web/data.json.new
	mv web/data.json.new web/data.json
	echo "Iteration complete"
done
