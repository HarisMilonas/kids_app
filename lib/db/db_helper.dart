import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart' as sql;


class SQLHelper {
  // create tables
  static Future<void> createTables(sql.Database database) async {
    await database.execute('''CREATE TABLE calendar(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      date TEXT NOT NULL UNIQUE,
      duration TEXT,
      details JSON,
      comments TEXT
    )
''');
  }

// open or Create db
// open or Create db
  static Future<sql.Database> db() async {
    return sql.openDatabase("kids.db", version: 1,
        onCreate: (sql.Database database, int version) async {
      await createTables(database);
      await insertRowsForYear2023(database);
    }, onUpgrade: (db, oldVersion, newVersion) async {
      if (oldVersion < newVersion) {}
    });
  }

  static Future<void> insertRowsForYear2023(sql.Database database) async {
  try {
    var batch = database.batch();
    // Add 20 days from December 10, 2023, to December 31, 2023
    DateTime startDate = DateTime(2023, 12, 10);
    DateTime endDate = DateTime(2023, 12, 31);

    for (DateTime date = startDate;
        date.isBefore(endDate.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))) {
      // Format the date as 'yyyy-MM-dd'
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);

      // Add each record to the batch
      batch.insert(
        'calendar',
        {'date': formattedDate, 'duration': null, 'details': null, 'comments': null},
        conflictAlgorithm: sql.ConflictAlgorithm.ignore,
      );
    }

    for (int month = 1; month <= 12; month++) {
      int daysInMonth = DateTime(2024, month + 1, 0).day;
      for (int day = 1; day <= daysInMonth; day++) {
        DateTime date = DateTime(2024, month, day);
        // Format the date as 'yyyy-MM-dd'
        String formattedDate = DateFormat('yyyy-MM-dd').format(date);

        batch.insert(
          'calendar',
          {'date': formattedDate, 'duration': null, 'details': null, 'comments': null},
          conflictAlgorithm: sql.ConflictAlgorithm.ignore,
        );
      }
    }
    await batch.commit();
  } catch (error) {
    debugPrint("Error: ${error.toString()}");
  }
}
}


//   static Future<int> createData(Map<String, dynamic> model) async {
//     final db = await SQLHelper.db();
//     // Logger().d(model);
//     final id = await db.insert('service_items', model,
//         conflictAlgorithm: sql.ConflictAlgorithm.replace);
//     return id;
//   }

//   static Future<void> createMultipleData(
//       List<Map<String, dynamic>> models) async {
//     final db = await SQLHelper.db();

//     final batch = db.batch();

//     for (var model in models) {
//       batch.insert("service_items", model);
//     }

//     await batch.commit();
//   }

//   static Future<List<Map<String, dynamic>>> getAllAssignmentData(
//       String assignmentId) async {
//     final db = await SQLHelper.db();
//     if (kDebugMode) {
//       print('we got data from database!');
//     }
//     return db.query('service_items',
//         where: "assignment_id = ?", whereArgs: [assignmentId], orderBy: 'id');
//     // return db.rawQuery(
//     //     "SELECT * FROM service_items WHERE service_id = ? ORDER BY id", [serviceId]);
//   }

//   static Future<List<Map<String, dynamic>>> getAllData(
//       String serviceId, String assignmentId) async {
//     final db = await SQLHelper.db();
//     if (kDebugMode) {
//       print('we got data from database!');
//     }
//     return db.query('service_items',
//         where: "service_id = ? AND assignment_id = ?",
//         whereArgs: [serviceId, assignmentId],
//         orderBy: 'id');
//     // return db.rawQuery(
//     //     "SELECT * FROM service_items WHERE service_id = ? ORDER BY id", [serviceId]);
//   }

//   static Future<List<Map<String, dynamic>>> getSingleData(int id) async {
//     final db = await SQLHelper.db();
//     return db.query('service_items',
//         where: 'id = ? ', whereArgs: [id], limit: 1);
//   }

//   static Future<int> updateData(int? id, Map<String, dynamic> model) async {
//     final db = await SQLHelper.db();

//     final result = await db.update(
//       'service_items',
//       model,
//       where: "id = ?",
//       whereArgs: [id],
//     );
//     return result;
//   }

//   static Future<void> deleteData(int? id) async {
//     final db = await SQLHelper.db();
//     try {
//       await db.delete('service_items', where: "id = ?", whereArgs: [id]);
//     } catch (e) {
//       //some action here
//     }
//   }

//   static Future<void> deleteModel(String assignmentId, String serviceId) async {
//     final db = await SQLHelper.db();
//     try {
//       await db.delete('service_items',
//           where: "assignment_id = ? AND service_id = ?",
//           whereArgs: [assignmentId, serviceId]);
//     } catch (e) {
//       //some action here
//     }
//   }

//   static Future<void> deleteServices(String assignmentId) async {
//     final db = await SQLHelper.db();
//     try {
//       await db.delete('service_items',
//           where: "assignment_id = ?", whereArgs: [assignmentId]);
//     } catch (e) {
//       //some action here
//     }
//   }

//   void resetAutoIncrementID() async {
//     // Step 1: Open the database
//     final db = await SQLHelper.db();

//     // Step 2: Delete all rows from the table
//     await db.delete('service_items');

//     // Step 3: Reset the auto-increment ID
//     await db.rawDelete(
//         "UPDATE SQLITE_SEQUENCE SET SEQ=0 WHERE NAME='service_items'");

//     // Step 4: Close the database
//     await db.close();
//   }

// // Assuming you have a database instance called 'database'

// // Assuming you have a database instance called 'database'

//   Future<bool> checkSerialNumberExists(Object? serialNumber) async {
//     final db = await SQLHelper.db();
//     final jsonColumns = await db.query('service_items');

//     for (final jsonColumn in jsonColumns) {
//       final jsonString = jsonColumn['item_details'].toString();
//       final jsonObject = jsonDecode(jsonString);

//       if (jsonObject is Map<String, dynamic> &&
//           jsonObject.containsKey('serial_number')) {
//         final serialNumberValue = jsonObject['serial_number'];

//         if (serialNumberValue == serialNumber.toString()) {
//           return true; // Serial number found in JSON column
//         }
//       }
//     }
//     return false; // Serial number not found in any JSON column
//   }

