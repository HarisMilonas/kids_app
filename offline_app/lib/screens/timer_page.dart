import 'dart:async';
import 'package:flutter/material.dart';
import 'package:offline_app/styles/text_styles.dart';

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
              height: MediaQuery.of(context).size.height * 0.30,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                      colors: [Colors.deepPurpleAccent, Colors.cyanAccent])),
              child: Center(
                child: Column(
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
                          onPressed: resetTimer,
                          child: const Text('Ξεκίνα απο την αρχή', style: TextStyle( fontWeight: FontWeight.w800, fontSize: 16),),
                        ),
                        ElevatedButton(
                          onPressed: startPauseTimer,
                          child: Text(isRunning ? 'Σταμάτα' : 'Ξεκίνα', style: const TextStyle( fontWeight: FontWeight.w800, fontSize: 16)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
