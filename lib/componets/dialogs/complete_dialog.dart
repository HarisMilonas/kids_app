

 import 'package:flutter/material.dart';
import 'package:offline_app/styles/color_style.dart';

void completeDialog(BuildContext context, void Function()? onPressed) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                  onPressed: onPressed,
                  //  () async {
                  //   loadingDialog(context);
                  //   int elapsedMinutes = (seconds / 60).floor();
                  //   await CalendarController.createOrUpdateDay(elapsedMinutes);
                  //   resetTimer();
                  //   if (mounted) {
                  //     Navigator.pop(context);
                  //     Navigator.pop(context);
                  //   }
                  // },
                  child: const Text(
                    "Ναι",
                  )),
            ],
          ));