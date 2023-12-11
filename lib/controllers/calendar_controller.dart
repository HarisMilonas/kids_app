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

  static Future<Calendar?> createOrUpdateDay(int duration) async {
    try {
      var db = await SQLHelper.db();

      // Get the current date and time
      var currentDate = DateTime.now();

      String currentDateString =
          DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Calculate the starting date by subtracting the duration in minutes
      DateTime startingDate = currentDate.subtract(Duration(minutes: duration));

      // Format the starting date as 'yyyy-MM-dd'
      String startingDateString = DateFormat('yyyy-MM-dd').format(startingDate);

      // Query the database for the starting date
      var results = await db
          .query('calendar', where: "date = ?", whereArgs: [currentDateString]);

      // If a record for the starting date exists, update it
      if (results.isNotEmpty) {
        var item = Calendar.fromMap(results.first);

        int? dbDuration = int.tryParse(item.duration ?? '0');

        int totalDuration = duration + (dbDuration ?? 0) + 120;

        item.duration = totalDuration.toString();

        item.details != null
            ? item.details!.addAll({
                "start": DateFormat('yyyy-MM-dd HH:mm')
                    .format(startingDate)
                    .toString(),
                "end": DateFormat('yyyy-MM-dd HH:mm')
                    .format(currentDate)
                    .toString()
              })
            : item.details = {
                "start": DateFormat('yyyy-MM-dd HH:mm')
                    .format(startingDate)
                    .toString(),
                "end": DateFormat('yyyy-MM-dd HH:mm')
                    .format(currentDate)
                    .toString()
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
          details: {"start": startingDateString, "end": currentDateString},
          comments: null,
        );

        db.insert('calendar', newItem.toMap());
        debugPrint("Congratulations! New record created successfully");
      }
    } catch (error) {
      debugPrint(error.toString());
    }
    return null;
  }
}
