import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:offline_app/db/db_helper.dart';
import 'package:offline_app/models/calendar.dart';

class CalendarController extends Calendar {
  CalendarController({required super.date});

  // this fetched the calendar
  static Future<List<Calendar>> getAll() async {
    try {
      var db = await SQLHelper.db();

      List<Map<String, Object?>> rows = await db.query(
        'calendar',
        orderBy: 'date ASC',
      );

      return rows.map((row) => Calendar.fromMap(row)).toList();
    } catch (error) {
      //oops message
      debugPrint(error.toString());
      return [];
    }
  }

  static Future<void> createOrUpdateDay(int duration) async {
    duration = 143;

    if (duration > 0) {
      try {
        var db = await SQLHelper.db();

        // Get the current date and time
        // var currentDate = DateTime.now();

        var currentDate = DateTime(
          2023,
          12,
          15,
          2,
        );

        String currentDateString =
            DateFormat('yyyy-MM-dd HH:mm').format(currentDate);

        // Calculate the starting date by subtracting the duration in minutes
        DateTime startingDate =
            currentDate.subtract(Duration(minutes: duration));

        DateTime midnight = DateTime(
            currentDate.year, currentDate.month, currentDate.day, 0, 0, 0);

        // this condition only when the gap is between 12AM!
        if (currentDate.subtract(Duration(minutes: duration)).isBefore(DateTime(
            currentDate.year, currentDate.month, currentDate.day, 0, 0))) {
          var previousDayDuration = midnight.difference(startingDate).inMinutes;

          var nextDayDuration =
              Duration(minutes: duration - previousDayDuration).inMinutes;

          // Query the database for the date now
          var results = await db.query('calendar',
              where: "date = ?",
              whereArgs: [DateFormat("yyyy-MM-dd").format(currentDate)]);

          if (results.isNotEmpty) {
            // date time now item
            var item = Calendar.fromMap(results.first);

            item.details != null
                ? item.details!.addAll({
                    DateFormat('HH:mm').format(midnight).toString(): "start",
                    DateFormat('HH:mm').format(currentDate).toString(): "end"
                  })
                : item.details = {
                    DateFormat('HH:mm').format(midnight).toString(): "start",
                    DateFormat('HH:mm').format(currentDate).toString(): "end"
                  };

            int? totalPreviousDuration =
                int.tryParse(item.duration ?? '0')! + nextDayDuration;

            item.duration = totalPreviousDuration.toString();

            db.update('calendar', item.toMap(), where: 'id = ?', whereArgs: [
              item.id,
            ]);
            debugPrint("Congratulations! Duration saved successfully");
          }

          // Query the database for the previous now
          var resultsPreviousDay = await db.query('calendar',
              where: "date = ?",
              whereArgs: [DateFormat("yyyy-MM-dd").format(startingDate)]);

          if (resultsPreviousDay.isNotEmpty) {
            // date time now item
            var previousDayItem = Calendar.fromMap(resultsPreviousDay.first);

            previousDayItem.details != null
                ? previousDayItem.details!.addAll({
                    DateFormat('HH:mm').format(startingDate).toString():
                        "start",
                    DateFormat('HH:mm').format(midnight).toString(): "end"
                  })
                : previousDayItem.details = {
                    DateFormat('HH:mm').format(startingDate).toString():
                        "start",
                    DateFormat('HH:mm').format(midnight).toString(): "end"
                  };

            int? totalPreviousDuration =
                int.tryParse(previousDayItem.duration ?? '0')! +
                    previousDayDuration;

            previousDayItem.duration = totalPreviousDuration.toString();

            db.update('calendar', previousDayItem.toMap(),
                where: 'id = ?',
                whereArgs: [
                  previousDayItem.id,
                ]);
            debugPrint("Congratulations! Duration saved successfully");
          }
          return;
        }

        // Query the database for the  date now
        var results = await db.query('calendar',
            where: "date = ?",
            whereArgs: [DateFormat("yyyy-MM-dd").format(currentDate)]);

        // If a record for the starting date exists, update it
        if (results.isNotEmpty) {
          var item = Calendar.fromMap(results.first);

          int? dbDuration = int.tryParse(item.duration ?? '0');

          int totalDuration = duration + (dbDuration ?? 0);

          item.duration = totalDuration.toString();

          item.details != null
              ? item.details!.addAll({
                  DateFormat('HH:mm').format(startingDate).toString(): "start",
                  DateFormat('HH:mm').format(currentDate).toString(): "end"
                })
              : item.details = {
                  DateFormat('HH:mm').format(startingDate).toString(): "start",
                  DateFormat('HH:mm').format(currentDate).toString(): "end"
                };

          db.update('calendar', item.toMap(), where: 'id = ?', whereArgs: [
            item.id,
          ]);
          debugPrint("Congratulations! Duration saved successfully");
        } else {
          // If no record for the starting date exists, create a new one
          Calendar newItem = Calendar(
            date: currentDateString,
            duration: duration.toString(),
            details: {
              DateFormat('HH:mm').format(startingDate).toString(): "start",
              DateFormat('HH:mm').format(currentDate).toString(): "end"
            },
            comments: null,
          );

          db.insert('calendar', newItem.toMap());
          debugPrint("Congratulations! New record created successfully");
        }
      } catch (error) {
        debugPrint(error.toString());
      }
    }
  }
}
