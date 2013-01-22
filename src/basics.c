#include <stdio.h>
#include "sqlite3.h"
#include <stdlib.h>
#include <time.h>

int main(int argc, char** args)
{
    sqlite3_stmt *stmt;
    sqlite3 *handle;
    
    if(sqlite3_open_v2("gtfs.db", &handle, SQLITE_OPEN_READONLY, 0))
    {
        printf("Database connection failed\n");
        return -1;
    }

    // Calculate date offsets
    time_t now_time_t = time(NULL);
    char date[9];
    struct tm* now_tm;
    now_tm = localtime(&now_time_t);
    strftime(date, 100, "%Y%m%d", now_tm);

    now_tm->tm_hour = 12;
    now_tm->tm_min = 0;
    now_tm->tm_sec = 0;

    long seconds_into_day = now_time_t - (mktime(now_tm) - 12*60*60);

    if(sqlite3_prepare_v2(handle, 
        "select first_stop_info.stop_name, first_stop_info.stop_name, trips.trip_headsign, trips.trip_id "
        "from stop_times first_stop "
        "join stop_times second_stop on ( "
          "first_stop.stop_sequence+1=second_stop.stop_sequence "
          "and first_stop.trip_id = second_stop.trip_id "
        ") "
        "join trips on trips.trip_id = first_stop.trip_id "
        "join stops first_stop_info on first_stop_info.stop_id = first_stop.stop_id "
        "join stops second_stop_info on second_stop_info.stop_id = second_stop.stop_id "
        "where trips.service_id in (select service_id from calendar_dates where date=\"20130121\") "
        "and first_stop.departure_time < 74096  "
        "and second_stop.departure_time > 74096 "
        ,-1, &stmt, NULL)) {
        printf("%s", "Error preparing main SQL statement.");
        exit(1);
    }

    printf("Date is %s, time is %ld.\n", date, seconds_into_day);
    // sqlite3_bind_text(stmt, 1, date, -1, SQLITE_STATIC);
    // sqlite3_bind_int(stmt, 2, seconds_into_day);

    printf("{\"locs\": [");
    fflush(stdout);
    char delim = ' ';
    while(SQLITE_ROW == sqlite3_step(stmt)) {
        putchar(delim);
        delim = ',';

        printf("%s", "{\"from\":\"");
        printf("%s", (const char *) sqlite3_column_text(stmt, 0));
        printf("%s", "\",\"to\":\"");
        printf("%s", (const char *) sqlite3_column_text(stmt, 1));
        printf("%s", "\",\"trip\":\"");
        printf("%s", (const char *) sqlite3_column_text(stmt, 2));
        printf("\",\"trip_id\":%lld}", sqlite3_column_int64(stmt, 3));
    }
    puts("]}");

    
    // Close the handle to free memory
    sqlite3_close(handle);
    return 0;
}
