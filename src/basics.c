#include <stdio.h>
#include "sqlite3.h"
#include <stdlib.h>
#include <time.h>
#include <math.h>

static sqlite3 *handle;

struct shape_pt {
    double lat;
    double lon;
    double dist_traveled;
};

static void find_intermediary(const struct shape_pt * prev_shape, const struct shape_pt * next_shape, const double fraction_complete, double *lat, double *lon) {
    double m, delta_y, delta_x;
    // x = longitude

    if (fraction_complete == 1 || (prev_shape->lat == next_shape->lat && prev_shape->lon == next_shape->lon)) {
        *lat = prev_shape->lat;
        *lon = prev_shape->lon;
        return;
    }

    delta_y = prev_shape->lat - next_shape->lat;
    delta_x = prev_shape->lon - prev_shape->lon;
    m = delta_y / delta_x;
    delta_y = fabs(delta_y);
    delta_x = fabs(delta_x);

    if (isnan(m) || isinf(m)) {
        *lon = prev_shape->lon;
        *lat = prev_shape->lat + (next_shape->lat - prev_shape->lat) * fraction_complete;
    } else {
        *lon = prev_shape->lon + (next_shape->lon - prev_shape->lon) * fraction_complete;
        *lat = m * (*lon - prev_shape->lon) + prev_shape->lat;
    }
}

static void calc_lat_lon(int64_t shape_id, double dist_traveled, double *lat, double *lon) {
    static sqlite3_stmt *lat_lon_stmt = NULL;
    struct shape_pt prev_shape, next_shape;
    double fraction_complete;

    if (lat_lon_stmt == NULL) {
        if(sqlite3_prepare_v2(handle, 
            "select shape_pt_lat, shape_pt_lon, shape_dist_traveled "
            "from shapes "
            "where shape_id = ?1 "
            "and (start_relevancy < ?2 or start_relevancy = 0)"
            "and end_relevancy >= ?2 "
            "order by shape_pt_sequence asc "
            "limit 2"
            ,-1, &lat_lon_stmt, NULL)) {
            printf("%s", "Error preparing lat lon SQL statement");
            exit(1);
        }
    }

    sqlite3_bind_int64(lat_lon_stmt, 1, shape_id);
    sqlite3_bind_double(lat_lon_stmt, 2, dist_traveled);
    if(SQLITE_ROW != sqlite3_step(lat_lon_stmt)) {
        fflush(stdout);
        printf("Error executing lat lon SQL statement for shape %lld, distance %f.", shape_id, dist_traveled);
        exit(1);
    }

    prev_shape.lat = sqlite3_column_double(lat_lon_stmt, 0);
    prev_shape.lon = sqlite3_column_double(lat_lon_stmt, 1);
    prev_shape.dist_traveled = sqlite3_column_double(lat_lon_stmt, 2);

    if(SQLITE_DONE == sqlite3_step(lat_lon_stmt)) {
        // Only 1 result
        next_shape = prev_shape;
        fraction_complete = 1;
    } else {
        next_shape.lat = sqlite3_column_double(lat_lon_stmt, 0);
        next_shape.lon = sqlite3_column_double(lat_lon_stmt, 1);
        next_shape.dist_traveled = sqlite3_column_double(lat_lon_stmt, 2);
        fraction_complete = (dist_traveled - prev_shape.dist_traveled) / (next_shape.dist_traveled - prev_shape.dist_traveled);
    }

    sqlite3_reset(lat_lon_stmt);
    find_intermediary(&prev_shape, &next_shape, fraction_complete, lat, lon);
}

int main(int argc, char** args)
{
    sqlite3_stmt *main_stmt;
    
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

    int64_t seconds_into_day = now_time_t - (mktime(now_tm) - 12*60*60);

    if(sqlite3_prepare_v2(handle, 
        "select first_stop_info.stop_name, second_stop_info.stop_name, trips.trip_headsign, trips.trip_id, trips.shape_id, first_stop.departure_time, second_stop.departure_time, first_stop.shape_dist_traveled, second_stop.shape_dist_traveled "
        "from stop_times first_stop "
        "join stop_times second_stop on ( "
          "first_stop.stop_sequence+1=second_stop.stop_sequence "
          "and first_stop.trip_id = second_stop.trip_id "
        ") "
        "join trips on trips.trip_id = first_stop.trip_id "
        "join stops first_stop_info on first_stop_info.stop_id = first_stop.stop_id "
        "join stops second_stop_info on second_stop_info.stop_id = second_stop.stop_id "
        "where trips.service_id in (select service_id from calendar_dates where date=?1) "
        "and first_stop.departure_time < ?2  "
        "and second_stop.departure_time > ?2 "
        ,-1, &main_stmt, NULL)) {
        printf("%s", "Error preparing main SQL statement.");
        exit(1);
    }

    #ifdef DEBUG
    printf("Date is %s, time is %lld.\n", date, seconds_into_day);
    #endif

    sqlite3_bind_text(main_stmt, 1, date, -1, SQLITE_STATIC);
    sqlite3_bind_int(main_stmt, 2, seconds_into_day);

    printf("{\"locs\": [");
    fflush(stdout);
    char delim = ' ';
    double lat, lon, dist_traveled, fraction_complete, second_dist_traveled, first_dist_traveled;
    int64_t shape_id, first_dept_time, second_dept_time;

    #ifdef DEBUG
    int n = 0;
    #endif
    while(SQLITE_ROW == sqlite3_step(main_stmt)) {
        #ifdef DEBUG
        n++;
        if (n > 5) break;
        #endif

        putchar(delim);
        delim = ',';

        first_dept_time = sqlite3_column_int64(main_stmt, 5);
        second_dept_time = sqlite3_column_int64(main_stmt, 6);
        first_dist_traveled = sqlite3_column_double(main_stmt, 7);
        second_dist_traveled = sqlite3_column_double(main_stmt, 8);
        shape_id = sqlite3_column_int64(main_stmt, 4);
        
        fraction_complete = (seconds_into_day - first_dept_time) * 1.0 / (second_dept_time - first_dept_time);
        dist_traveled = fraction_complete * (second_dist_traveled - first_dist_traveled) + first_dist_traveled;

        printf("%s", "{\"from\":\"");
        printf("%s", (const char *) sqlite3_column_text(main_stmt, 0));
        printf("%s", "\",\"to\":\"");
        printf("%s", (const char *) sqlite3_column_text(main_stmt, 1));
        printf("%s", "\",\"trip\":\"");
        printf("%s", (const char *) sqlite3_column_text(main_stmt, 2));
        printf("%s", "\",\"trip_id\":");
        printf("%lld", sqlite3_column_int64(main_stmt, 3));

        #ifdef DEBUG
        printf(",\"dist_traveled\":%f,\"fraction_complete\":%f", fraction_complete, dist_traveled);
        #endif

        // Calculate here so we get some debugging info if this call fails.
        calc_lat_lon(shape_id, dist_traveled, &lat, &lon);

        #ifdef DEBUG
        printf(",\"lat\":%f,\"lon\":%f}\n", lat, lon);
        #else
        printf(",\"lat\":%f,\"lon\":%f}", lat, lon);
        #endif
    }
    puts("]}");

    
    // Close the handle to free memory
    sqlite3_finalize(main_stmt);
    sqlite3_close(handle);
    return 0;
}
