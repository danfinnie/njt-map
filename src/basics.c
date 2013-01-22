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
    now_tm = gmtime(&now_time_t);
    strftime(date, 100, "%Y%m%d", now_tm);

    now_tm->tm_hour = 12;
    now_tm->tm_min = 0;
    now_tm->tm_sec = 0;

    long seconds_into_day = now_time_t - (mktime(now_tm) - 12*60*60);

    // Calculate service IDs into a comma separated string.
    char service_ids[400] = {'\0'};
    int newlen;
    sqlite3_stmt * service_id_stmt;
    if(sqlite3_prepare_v2(handle, "select service_id from calendar_dates where date=?", -1, &service_id_stmt, 0)) {
        printf("Could not extract service ids for date %s and time %ld.\n", date, seconds_into_day);
        return -1;
    }
    sqlite3_bind_text(service_id_stmt, 1, date, 8, SQLITE_TRANSIENT);
    while(SQLITE_ROW == sqlite3_step(service_id_stmt)) {
        newlen = strlcat(service_ids, (const char*) sqlite3_column_text(service_id_stmt, 0), 400-2);
        service_ids[newlen++] = ',';
        service_ids[newlen] = '\0';
    }
    service_ids[newlen-1] = '\0'; // Remove trailing comma.

    printf("%s", service_ids);

    // printf("%s\n", date);
    // printf("%lu", seconds_into_day);

    // if(sqlite3_prepare_v2(handle, 
    //     "select *"
    //             from stop_times first_stop
    //             join stop_times second_stop on (
    //               first_stop.stop_sequence+1=second_stop.stop_sequence
    //               and first_stop.trip_id = second_stop.trip_id
    //             )
    //             join trips on trips.trip_id = first_stop.trip_id
    //             join stops first_stop_info on first_stop_info.stop_id = first_stop.stop_id
    //             join stops second_stop_info on second_stop_info.stop_id = second_stop.stop_id
    //             where trips.service_id in (#{service_ids.join(',')})
    //             and first_stop.departure_time < :time 
    //             and second_stop.departure_time > :time
    //     -1))
    
    // Close the handle to free memory
    sqlite3_close(handle);
    return 0;
}
