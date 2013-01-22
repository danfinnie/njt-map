all: bin/njt_pos gtfs.db web/data.json
	true
bin/njt_pos: force_look
	$(MAKE) -C src $(MFLAGS) && cp src/njt_pos bin/njt_pos
gtfs.db:
	sqlite3 gtfs.db < schema.sql
	./init_db.rb
	sqlite3 gtfs.db < index.sql
	chmod ugo-w gtfs.db
web/data.json: gtfs.db
	bin/njt_pos > web/data.json
json: gtfs.db
	bin/njt_pos > web/data.json
clean:
	rm -f gtfs.db
	make -C src clean
force_look:
	true
