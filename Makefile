gtfs.db:
	sqlite3 gtfs.db < schema.sql
	./init_db.rb
	chmod ugo-w gtfs.db
clean:
	rm -f gtfs.db
