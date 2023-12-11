import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:offline_app/componets/page_router.dart';
import 'package:offline_app/controllers/calendar_controller.dart';
import 'package:offline_app/models/calendar.dart';
import 'package:offline_app/screens/edit_day._page.dart';
import 'package:offline_app/styles/color_style.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int columnCount = 7;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: FutureBuilder(
          future: CalendarController.getAll(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Calendar>> snapshot) {
            if (snapshot.hasData) {
              List<Calendar> calendarDays = snapshot.data!;

              // make a list with the month and the days inside the days key
              List<Map<String, dynamic>> groupedItems =
                  groupCalendarItemsByMonthYear(
                      calendarDays.map((day) => day.toMap()).toList());

              return ListView.builder(
                itemCount: groupedItems.length,
                itemBuilder: (context, index) {
                  String headerTitle = groupedItems[index]['month_year'];

                  // Build header for each month
                  Widget header = ListTile(
                    tileColor: Colors.white,
                    title: Center(
                      child: Text(
                        headerTitle,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );

                  DateTime firstDayOfMonth =
                      DateTime.parse(groupedItems[index]["days"][0]["date"]);
                  int startingIndex = (firstDayOfMonth.weekday + 6) %
                      7; // Adjust index to start from Monday

                  // Build list of cards for each month
                  List<Widget> cards = (groupedItems[index]["days"]
                          as List<Map<String, dynamic>>)
                      .map((item) {
                    DateTime dateTime = DateTime.parse(item["date"]);

                    // Get abbreviated day of the week (e.g., "Mon", "Tue")
                    String dayOfWeek = DateFormat('EEE').format(dateTime);

                    // Get day of the month as a number
                    String dayOfMonth = DateFormat('d').format(dateTime);

                    bool isCurrentDate =
                        DateFormat('yyyy-MM-dd').format(DateTime.now()) ==
                            item['date'];

                    // Replace with your card widget creation logic
                    return Tooltip(
                      triggerMode: TooltipTriggerMode.longPress,
                      message:
                          "Μασελάκι: 6 ώρες σήμερα.\nΑυτή την εβδομάδα: 15 ώρες.",
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                              CustomPageRouter.fadeThroughPageRoute(EditDayPage(
                            selectedDay: Calendar.fromMap(item),
                          )));
                        },
                        child: Card(
                          color: isCurrentDate ? Colors.yellow : Colors.white,
                          elevation: 5,
                          shadowColor: Colors.black,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          margin: const EdgeInsets.all(5),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [Text(dayOfWeek), Text(dayOfMonth)],
                          ),
                        ),
                      ),
                    );
                  }).toList();

                  for (int i = 0; i < startingIndex; i++) {
                    cards.insert(0,  Tooltip(
                    
                      message: "",
                      child:Container()
                    ) );
                  }

                  return Column(
                    children: [
                      header,
                      SizedBox(
                        height: 280,
                        child: AnimationLimiter(
                          child: GridView.count(
                            physics:
                                const NeverScrollableScrollPhysics(), //so we won't scroll the days only the big list with the months
                            crossAxisCount: columnCount,
                            children: List.generate(
                              cards.length,
                              (int index) {
                                return AnimationConfiguration.staggeredGrid(
                                  position: index,
                                  duration: const Duration(milliseconds: 375),
                                  columnCount: columnCount,
                                  child: ScaleAnimation(
                                    child: FadeInAnimation(
                                      child: cards[index],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: Text(
                  "Ουπς!",
                  style: TextStyle(
                      color: customDialogPink(), fontWeight: FontWeight.bold),
                ),
                content: const Center(
                    child: Text(
                        'Κάτι δεν πηγε πολύ καλα, προσπάθησε να ανοίξεις ξανα την εφαρμογή!')),
              );
            } else {
              return Center(
                child: CircularProgressIndicator(
                  color: customDialogPink(),
                ),
              );
            }
          }),
    ));
  }

  List<Map<String, dynamic>> groupCalendarItemsByMonthYear(
      List<Map<String, dynamic>> calendarItems) {
    Map<String, List<Map<String, dynamic>>> groupedItems = {};

    for (var item in calendarItems) {
      String dateString = item['date'];
      DateTime date = DateTime.parse(dateString);

      String monthYear = DateFormat('MMMM yyyy').format(date);

      groupedItems.putIfAbsent(monthYear, () => []);
      groupedItems[monthYear]!.add(item);
    }

    // Convert to the desired format
    List<Map<String, dynamic>> result = groupedItems.entries.map((entry) {
      return {
        'month_year': entry.key,
        'days': entry.value,
      };
    }).toList();
    return result;
  }
}
