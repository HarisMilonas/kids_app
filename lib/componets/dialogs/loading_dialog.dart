import 'package:flutter/material.dart';

void loadingDialog(BuildContext context) {
  showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => const PopScope(
            canPop: false,
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 252, 23, 7)
                    // Color.fromARGB(255, 234, 134, 168)
                    ),
              ),
            ),
          ));
}
