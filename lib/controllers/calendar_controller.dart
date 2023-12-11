import 'package:flutter/material.dart';
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
}
