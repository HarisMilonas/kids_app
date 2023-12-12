 
 import 'package:flutter/material.dart';
import 'package:offline_app/styles/color_style.dart';

void resetDialog(BuildContext context, void Function()? onPressed) => showDialog(
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
                  onPressed: onPressed,
                  //  () {
                  //   resetTimer();
                  //   Navigator.pop(context);
                  // },
                  child: const Text(
                    "Ναι",
                  )),
            ],
          ));