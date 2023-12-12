import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:offline_app/models/calendar.dart';
import 'package:offline_app/styles/text_styles.dart';

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
  bool readOnly = true;
  String duration = '';
  String date = '';
  Map<String, dynamic> hours = {};

  @override
  void initState() {
    duration = widget.selectedDay.duration ?? '0';
    hours = widget.selectedDay.details ?? {};
    date = widget.selectedDay.date;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.50,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.orangeAccent,
              // gradient: const LinearGradient(
              //     colors: [Colors.deepPurpleAccent, Colors.cyanAccent])
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: columnRows(),
              ),
            )),
      ),
    );
  }

  List<Widget> columnRows() {
    List<Widget> items = [];

    DateTime formattedDate = DateTime.parse(date);

    String dayTitle = DateFormat('yMMMMEEEEd').format(formattedDate);

    if (hours.isNotEmpty) {
      items.add(Center(
          child: Text(
        dayTitle,
        style: editPageStyle(),
      )));
      items.add(const SizedBox(height: 50));
      items.add(Center(child: Text("Today's hours", style: editPageStyle(),)));
      items.add(const SizedBox(height: 15));

      List<String> keys = hours.keys.toList();

      // Iterate through the map, taking two maps at a time
      for (int i = 0; i < keys.length; i += 2) {
        String key1 = keys[i];
        String? key2 = (i + 1 < hours.length) ? keys[i + 1] : null;

        var row = hoursRow(key1, key2);

        items.add(row);
        items.add(const SizedBox(height: 15));
      }
    }
    double total = 0;
    if (duration != '0') {
      total = double.tryParse(duration)! / 60;
    }
    items.add(const SizedBox(height: 20));
    items.add(totalWidget(total));
    return items;
  }

  Column totalWidget(double total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Total Hours Today",
          style: editPageStyle(),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  total.toStringAsFixed(1),
                  style: editPageStyle(),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Row hoursRow(String key1, String? key2) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              key1,
              style: editPageStyle(),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          "-",
          style: editPageStyle(),
        ),
        const SizedBox(width: 15),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Center(
            child: Text(
              key2 ?? "00:00",
              style: editPageStyle(),
            ),
          ),
        ),
      ],
    );
  }
}
