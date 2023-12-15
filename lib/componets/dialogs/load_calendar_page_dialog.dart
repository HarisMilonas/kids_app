import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

void calendarDialog(BuildContext context) async {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.transparent,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: LoadingAnimationWidget.twistingDots(
                leftDotColor: const Color(0xFF1A1A3F),
                rightDotColor: const Color(0xFFEA3799),
                size: 100,
              ),
            ),
          ],
        ),
      );
    },
  );
  await Future.delayed(const Duration(seconds: 1));
  if (context.mounted) {
    Navigator.pop(context);
  }

  
}
