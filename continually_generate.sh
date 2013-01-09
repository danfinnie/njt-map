while :
do
	./njt_pos > web/data.json.new
	mv web/data.json.new web/data.json
	echo "Iteration complete"
done