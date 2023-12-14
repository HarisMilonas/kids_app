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
  String duration = '';
  String date = '';
  Map<String, dynamic> hours = {};
  final _formKey = GlobalKey<FormState>();
  List<TextEditingController> controllersList = [];
  String dayTitle = '';

  @override
  void initState() {
    duration = widget.selectedDay.duration ?? '0';
    hours = widget.selectedDay.details ?? {};
    date = widget.selectedDay.date;
    dayTitle = DateFormat('yMMMMEEEEd').format(DateTime.parse(date));

    _addControllers();

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

    // DateTime formattedDate = DateTime.parse(date);

    // String dayTitle = DateFormat('yMMMMEEEEd').format(formattedDate);

    // items.add(
    //   Center(
    //     child: Text(
    //   dayTitle,
    //   style: editPageStyle(),
    // ))
    // );
    items.add(const SizedBox(height: 50));

    if (hours.isNotEmpty) {
      items.add(Center(
          child: Text(
        "Today's hours",
        style: editPageStyle(),
      )));
      items.add(const SizedBox(height: 15));

      // List<String> keys = hours.keys.toList();

      // Iterate through the map, taking two maps at a time
      for (int i = 0; i < controllersList.length; i += 2) {
        TextEditingController controllerKeyStart = controllersList[i];
        TextEditingController? controllerKeyEnd =
            (i + 1 < controllersList.length) ? controllersList[i + 1] : null;

        var row = hoursRow(controllerKeyStart, controllerKeyEnd);

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

    // items.add(sumbitButton());

    return items;
  }

  Center sumbitButton() {
    return Center(
      child: ElevatedButton(
          onPressed: () async {
            bool isValid = _formKey.currentState!.validate();
            if (!isValid) {
              return;
            }

            Map<String, dynamic> newHours = {};
            int newDuration = 0;

            for (int i = 0; i < controllersList.length; i += 2) {
              DateTime startTime =
                  DateFormat('HH:mm').parse(controllersList[i].text);
              DateTime endTime =
                  DateFormat('HH:mm').parse(controllersList[i + 1].text);

              newHours.isNotEmpty
                  ? newHours.addAll({
                      DateFormat('HH:mm').format(startTime): "start",
                      DateFormat('HH:mm').format(endTime): "end"
                    })
                  : newHours = {
                      DateFormat('HH:mm').format(startTime): "start",
                      DateFormat('HH:mm').format(endTime): "end"
                    };

              // Calculate the duration using Duration constructor
              Duration twentyFourduration;
              if (endTime.isAfter(startTime)) {
                twentyFourduration = endTime.difference(startTime);
              } else {
                // If the end time is earlier than the start time (crossing midnight)
                twentyFourduration = Duration(
                  hours: 24 - startTime.hour + endTime.hour,
                  minutes: endTime.minute - startTime.minute,
                );
              }

              // Accumulate the durations in minutes
              newDuration += twentyFourduration.inMinutes;

              widget.selectedDay.details = newHours;
              widget.selectedDay.duration = newDuration.toString();

              await CalendarController.updateDay(widget.selectedDay);
              setState(() {
                hours = newHours;
                duration = newDuration.toString();
              });
            }
          },
          child: const Text("Save")),
    );
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
              textAlign: TextAlign.center,
              style: editPageStyle(),
              controller: startController,
              validator: CustomValidators().timeValidator,
              decoration: const InputDecoration(border: InputBorder.none),
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
              textAlign: TextAlign.center,
              style: editPageStyle(),
              controller: endController,
              validator: CustomValidators().timeValidator,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
        ),
      ],
    );
  }

  void _addControllers() {
    if (hours.isNotEmpty) {
      hours.forEach((key, value) {
        controllersList.add(TextEditingController(text: key));
      });
    }
  }
}
