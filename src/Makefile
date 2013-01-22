njt_pos: basics.o sqlite3.o
	gcc -o njt_pos sqlite3.o basics.o
sqlite.o: sqlite3.c
	gcc -c -o sqlite3.o -DSQLITE_THREADSAFE=0 -DSQLITE_OMIT_LOAD_EXTENSION sqlite3.c
basics.o: basics.c
	gcc -c -std=c99 -o basics.o -g -mtune=native basics.c
clean:
	rm -rf njt_pos basics.o sqlite3.o
