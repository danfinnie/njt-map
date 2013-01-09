gtfs.db:
	sqlite3 gtfs.db < schema.sql
	./init_db.rb
	chmod ugo-w gtfs.db
web/data.json: gtfs.db
	./njt_pos > web/data.json
json: gtfs.db
	./njt_pos > web/data.json
clean:
	rm -f gtfs.db
