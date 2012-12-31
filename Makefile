gtfs.db:
	sqlite3 gtfs.db < schema.sql
	./init_db.rb
clean:
	rm gtfs.db