PERF_OPTIONS = -O3 -march=x86-64 -mtune=nocona -pipe
SQLITE_OPTIONS = -DSQLITE_THREADSAFE=0 -DSQLITE_OMIT_LOAD_EXTENSION -DSQLITE_TEMP_STORE=2

njt_pos: basics.o sqlite3.o
	gcc $(PERF_OPTIONS) -o njt_pos -O3 -lsqlite3 basics.o
sqlite3.o: sqlite3.c
	gcc $(PERF_OPTIONS) $(SQLITE_OPTIONS) -c -o sqlite3.o sqlite3.c
basics.o: basics.c
	gcc $(PERF_OPTIONS) -c -std=c99 -o basics.o basics.c
clean:
	rm -rf njt_pos basics.o sqlite3.o
