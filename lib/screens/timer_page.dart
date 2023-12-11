import 'dart:async';
import 'package:flutter/material.dart';
import 'package:offline_app/componets/loading_dialog.dart';
import 'package:offline_app/componets/page_router.dart';
import 'package:offline_app/controllers/calendar_controller.dart';
import 'package:offline_app/screens/calendar_page.dart';
import 'package:offline_app/styles/color_style.dart';
import 'package:offline_app/styles/text_styles.dart';
import 'package:sqlite_viewer/sqlite_viewer.dart';

class TimerPage extends StatefulWidget {
  const TimerPage({Key? key}) : super(key: key);

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  bool isRunning = false;
  int seconds = 0;
  late Duration timerDuration;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '00:00:00');
    timerDuration = const Duration(seconds: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void startPauseTimer() {
    setState(() {
      isRunning = !isRunning;
      if (isRunning) {
        _startTimer();
      } else {
        _stopTimer();
      }
    });
  }

  void resetTimer() {
    setState(() {
      _stopTimer();
      seconds = 0;
      _controller.text = '00:00:00'; // Set to initial value
    });
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    Timer.periodic(oneSec, (Timer timer) {
      if (!isRunning) {
        timer.cancel();
      } else {
        setState(() {
          seconds++;
          _controller.text = formatDuration(Duration(seconds: seconds));
        });
      }
    });
  }

  void _stopTimer() {
    isRunning = false;
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitHours = twoDigits(duration.inHours);
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

    return "$twoDigitHours:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // photos
                  InkWell(
                    onTap: () {
                      completeDialog(context);
                    },
                    child: const CircleAvatar(
                      backgroundImage: null,
                    ),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const DatabaseList()));
                      },
                      child: const Text("See DB")),

                  //timer
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _controller.text,
                        style: timerStyle(),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              resetDialog(context);
                            },
                            child: const Text(
                              'Ξεκίνα απο την αρχή',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: startPauseTimer,
                            child: Text(isRunning ? 'Σταμάτα' : 'Ξεκίνα',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 16)),
                          ),
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
          ],
        ),
      ),
    );
  }

  Future<dynamic> resetDialog(BuildContext context) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            backgroundColor: Colors.tealAccent,
            title: Text(
              "Ουπς!",
              style: TextStyle(
                  color: customDialogPink(), fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Αν πατησεις 'ναι' θα μηδενίσεις το χρονόμετρο.",
                  style: TextStyle(
                      fontSize: 16,
                      color: customDialogPink(),
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Όχι")),
              const SizedBox(width: 10),
              ElevatedButton(
                  onPressed: () {
                    resetTimer();
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Ναι",
                  )),
            ],
          ));

  Future<dynamic> completeDialog(BuildContext context) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            backgroundColor: Colors.tealAccent,
            title: Text(
              // "Έβγαλες το μασελάκι σου;",
              "Complete service?",
              style: TextStyle(
                  color: customDialogPink(), fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  // "Να σταματησω το χρονομετρο;",
                  "do you want to stop the timer",
                  style: TextStyle(
                      fontSize: 16,
                      color: customDialogPink(),
                      fontWeight: FontWeight.bold),
                )
              ],
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Όχι")),
              const SizedBox(width: 10),
              ElevatedButton(
                  onPressed: () async {
                    loadingDialog(context);
                    int elapsedMinutes = (seconds / 60).floor();
                    await CalendarController.createOrUpdateDay(elapsedMinutes);
                    if (mounted) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    "Ναι",
                  )),
            ],
          ));
}
