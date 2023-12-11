import 'package:flutter/material.dart';
import 'package:offline_app/models/calendar.dart';

class EditDayPage extends StatefulWidget {
  const EditDayPage({
    required this.selectedDay,
    Key? key,
  }) : super(key: key);

  final Calendar selectedDay;

  @override
  State<EditDayPage> createState() => _EditDayPageState();
}

class _EditDayPageState extends State<EditDayPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child:  Center(
            child: Text("EDIT PAGEEE! date: ${widget.selectedDay.date}"),
          )),
    );
  }
}
