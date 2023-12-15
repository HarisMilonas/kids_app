import 'package:flutter/material.dart';

TextStyle headerStyles() {
  return const TextStyle(
      fontSize: 35,
      color: Colors.white,
      // Color.fromARGB(255, 58, 145, 122),
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic,
      decorationThickness: 15,
      decorationColor: Colors.white);
}

TextStyle timerStyle() {
  return const TextStyle(
      fontSize: 50,
      color: Color.fromARGB(255, 255, 245, 245),
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic,
      decorationThickness: 15,
      decorationColor: Colors.white);
}

TextStyle editPageStyle() {
  return const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  
}
