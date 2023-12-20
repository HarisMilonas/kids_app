import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:offline_app/componets/validators.dart';
import 'package:offline_app/controllers/calendar_controller.dart';
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
  String date = '';
  List<Map<String, dynamic>> hours = [];
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> controllersList = [];
  String dayTitle = '';

  @override
  void initState() {
    hours = widget.selectedDay.details ?? [];
    date = widget.selectedDay.date;
    dayTitle = DateFormat('yMMMMEEEEd').format(DateTime.parse(date));

    addControllers();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.75,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.orangeAccent,
              // gradient: const LinearGradient(
              //     colors: [Colors.deepPurpleAccent, Colors.cyanAccent])
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Center(
                    child: Text(
                  dayTitle,
                  style: editPageStyle(),
                )),
                SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: columnRows(),
                    ),
                  ),
                ),
                sumbitButton()
              ],
            )),
      ),
    );
  }

  List<Widget> columnRows() {
    List<Widget> items = [];

    items.add(const SizedBox(height: 50));

    if (hours.isEmpty) {
      hours.add(
          {"start": TextEditingController(), "end": TextEditingController()});

      addControllers();
    }

    if (hours.isNotEmpty) {
      items.add(Center(
          child: Text(
        //"Σημερινές ώρες"
        "Today's hours",
        style: editPageStyle(),
      )));
      items.add(const SizedBox(height: 15));

      // List<String> keys = hours.keys.toList();

      for (var map in controllersList) {
        var row = hoursRow(map['start'], map["end"]);
        items.add(row);
        items.add(const SizedBox(height: 10));
      }
    }
    double total = 0;
    for (var map in controllersList) {
      if (map.containsKey("start") && map.containsKey("end")) {
        total += timeDifference(map["start"].text, map["end"].text);
      }
    }
      items.add(const SizedBox(height: 20));
      items.add(totalWidget(total));

    return items;
  }

  Center sumbitButton() {
    return Center(
      child: ElevatedButton(
          onPressed: updateDay,
          child: Text(
            "Save",
            style: editPageStyle(),
          )),
    );
  }

  void updateDay() async {
    bool isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }

    List<Map<String, dynamic>> newHours = [];

    for (int i = 0; i < controllersList.length; i++) {
      DateTime startTime =
          DateFormat('HH:mm').parse(controllersList[i]["start"].text);
      DateTime endTime =
          DateFormat('HH:mm').parse(controllersList[i]["end"].text);

      newHours.isNotEmpty
          ? newHours.add({
              "start": DateFormat('HH:mm').format(startTime),
              "end": DateFormat('HH:mm').format(endTime)
            })
          : newHours = [
              {
                "start": DateFormat('HH:mm').format(startTime),
                "end": DateFormat('HH:mm').format(endTime)
              }
            ];
    }

    widget.selectedDay.details = newHours;
    await CalendarController.updateDay(widget.selectedDay);

    setState(() {
      hours = newHours;
    });
  }

  Column totalWidget(double total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Total Hours Today",
          // "Σύνολο",
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

  Row hoursRow(TextEditingController startController,
      TextEditingController? endController) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: SizedBox(
            width: 80,
            child: TextFormField(
              keyboardType: TextInputType.datetime,
              textAlign: TextAlign.center,
              style: editPageStyle(),
              controller: startController,
              validator: CustomValidators().timeValidator,
              decoration: const InputDecoration(
                  border: InputBorder.none, errorMaxLines: 2),
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
          padding: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: SizedBox(
            width: 80,
            child: TextFormField(
              keyboardType: TextInputType.datetime,
              textAlign: TextAlign.center,
              style: editPageStyle(),
              controller: endController,
              validator: CustomValidators().timeValidator,
              decoration: const InputDecoration(
                  border: InputBorder.none, errorMaxLines: 2),
            ),
          ),
        ),
      ],
    );
  }

  void addControllers() {
    if (hours.isNotEmpty) {
      for (var map in hours) {
        if (map.containsKey("start") && map.containsKey("end")) {
          controllersList.add({
            "start": TextEditingController(text: map["start"]),
            "end": TextEditingController(text: map["end"]),
          });
        }
        if (map.containsKey("start") && !map.containsKey("end")) {
          controllersList.add({
            "start": TextEditingController(text: map["start"]),
            "end": TextEditingController(),
          });
        }
      }
    }
  }

  double timeDifference(String startTime, String endTime) {
    // Convert the start and end times to minutes
    int startMinutes = int.parse(startTime.split(":")[0]) * 60 +
        int.parse(startTime.split(":")[1]);
    int endMinutes = int.parse(endTime.split(":")[0]) * 60 +
        int.parse(endTime.split(":")[1]);

    // Calculate the difference in minutes
    int differenceMinutes = endMinutes - startMinutes;

    // Convert the difference to a double format (or any other desired format)
    return differenceMinutes.toDouble() / 60;
  }

  double getTotalDayHours(Calendar day) {
    double sum = 0.0;
    if (day.details != null) {
      for (var map in day.details!) {
        if (map.containsKey("start") && map.containsKey("end")) {
          sum += timeDifference(map["start"], map["end"]);
        }
      }
    }
    return sum;
  }
}
