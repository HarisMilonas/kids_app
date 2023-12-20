import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:offline_app/componets/dialogs/complete_dialog.dart';
import 'package:offline_app/componets/dialogs/reset_dialog.dart';
import 'package:offline_app/componets/page_router.dart';
import 'package:offline_app/controllers/calendar_controller.dart';
import 'package:offline_app/models/calendar.dart';
import 'package:offline_app/screens/calendar_page.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({Key? key}) : super(key: key);

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: startPauseTimer(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              bool isRunning = snapshot.data!;

              print("IS RUNNING FROM FUTURE: $isRunning");
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height * 0.60,
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        // gradient: const LinearGradient(
                        //     colors: [Colors.deepPurpleAccent, Colors.cyanAccent])
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const SizedBox(height: 40),

                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              const DatabaseList()));
                                },
                                child: const Text("See DB")),

                            //timer
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 20),
                                Center(
                                    child: Text(isRunning
                                        ? "Timer has Started!"
                                        : "Press start to begin recording")),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        // resetDialog(context, () {
                                        //   resetDay();
                                        //   Navigator.pop(context);
                                        // });
                                      },
                                      child: const Icon(
                                        Icons.restart_alt,
                                        size: 45,
                                      ),
                                    ),
                                    ElevatedButton(
                                        onPressed: () async {
                                          await daysToSave();
                                          setState(() {});
                                        },
                                        child: Icon(
                                          isRunning
                                              ? Icons.pause_circle
                                              : Icons.not_started,
                                          size: 45,
                                        )),
                                  ],
                                ),
                              ],
                            ),

                            //flutter_staggered_animations 1.1.1
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.white),
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                      CustomPageRouter.fadeThroughPageRoute(
                                          const CalendarPage()));
                                },
                                child: const Icon(
                                  Icons.calendar_month_outlined,
                                  size: 80,
                                  color: Colors.deepPurpleAccent,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error.toString()}"),
              );
            } else {
              return Center(
                child: LoadingAnimationWidget.twistingDots(
                  leftDotColor: const Color(0xFF1A1A3F),
                  rightDotColor: const Color(0xFFEA3799),
                  size: 100,
                ),
              );
            }
          }),
    );
  }

  Future<void> daysToSave() async {
    DateTime today = DateTime.now();
    // DateTime today = DateTime(2023, 12, 21, 15, 30);

    String todayString = DateFormat("yyyy-MM-dd").format(today);

    Calendar? dbDay = await CalendarController.getSingleDay(todayString);

    if (dbDay == null) {
      // errorMessage = "Error fetching todays day from db";
      return;
    }

    bool wasPreviousDayUnsaved = await _savePreviousDay(today);

    if (wasPreviousDayUnsaved) {
      await _saveTodayWithMidnight(today, dbDay);
    } else {
      _saveToday(today, dbDay);
    }
  }

  Future<bool> _savePreviousDay(DateTime today) async {
    DateTime previousDay = today.subtract(const Duration(days: 1));

    String previousDayString = DateFormat("yyyy-MM-dd").format(previousDay);

    Calendar? dbPreviousDay =
        await CalendarController.getSingleDay(previousDayString);

    if (dbPreviousDay != null) {
      if (dbPreviousDay.details != null) {
        DateTime lastMinuteYesterday = DateTime(
            previousDay.year, previousDay.month, previousDay.day, 23, 59);

        String lastMinuteYesterdayString =
            DateFormat("HH:mm").format(lastMinuteYesterday);

        for (var map in dbPreviousDay.details!) {
          if (map.containsKey("start") && !map.containsKey("end")) {
            map["end"] = lastMinuteYesterdayString;
            await CalendarController.updateDay(dbPreviousDay);
            return true;
          }
        }
      }
    }
    return false;
  }

  _saveTodayWithMidnight(DateTime today, Calendar? dbDay) async {
    DateTime todaysFirstMinute =
        DateTime(today.year, today.month, today.day, 0, 0, 0);

    String todaysFirstMinuteString =
        DateFormat("HH:mm").format(todaysFirstMinute);

    String nowHour = DateFormat("HH:mm").format(today);

    if (dbDay?.details == null) {
      dbDay?.details = [
        {"start": todaysFirstMinuteString, "end": nowHour}
      ];
    } else {
      dbDay!.details!.add({"start": todaysFirstMinuteString, "end": nowHour});
    }

    // dbDay?.details == null
    //     ? dbDay?.details = [
    //         {"start": todaysFirstMinuteString, "end": nowHour}
    //       ]
    //     : dbDay!.details!
    //         .add({"start": todaysFirstMinuteString, "end": nowHour});

    await CalendarController.updateDay(dbDay!);
  }

  void _saveToday(DateTime today, Calendar dbDay) async {
    String nowHour = DateFormat("HH:mm").format(today);

    bool putEndKey = false;

    if (dbDay.details != null) {
      for (var map in dbDay.details!) {
        if (map.containsKey("start") && !map.containsKey("end")) {
          putEndKey = true;
          map["end"] = nowHour;
        }
      }
      if (!putEndKey) {
        dbDay.details!.add({"start": nowHour});
      }
    } else {
      dbDay.details = [
        {"start": nowHour}
      ];
    }

    await CalendarController.updateDay(dbDay);
  }

  // just to show the correct icon
  Future<bool> startPauseTimer() async {
    DateTime today = DateTime.now();

    // DateTime today = DateTime(2023, 12, 21, 15, 30);

    String todayString = DateFormat("yyyy-MM-dd").format(today);

    DateTime previousDay = today.subtract(const Duration(days: 1));
    String previousDayString = DateFormat("yyyy-MM-dd").format(previousDay);

    Calendar? dbToday = await CalendarController.getSingleDay(todayString);

    Calendar? dbPreviousDay =
        await CalendarController.getSingleDay(previousDayString);

    bool hasOnlyStart = false;

    if (dbToday != null) {
      if (dbToday.details != null) {
        for (var map in dbToday.details!) {
          if (map.containsKey("start") && !map.containsKey("end")) {
            hasOnlyStart = true;
            break;
          }
        }
      }
    }

    if (dbPreviousDay != null) {
      print("I AM HERE ${dbPreviousDay.date}");
      if (dbPreviousDay.details != null) {
        for (var map in dbPreviousDay.details!) {
          if (map.containsKey("start") && !map.containsKey("end")) {
            hasOnlyStart = true;
            break;
          }
        }
      }
    }

    return hasOnlyStart;
  }
}
