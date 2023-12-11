import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:offline_app/controllers/calendar_controller.dart';
import 'package:offline_app/models/calendar.dart';
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

              List<Map<String, dynamic>> groupedItems =
                  groupCalendarItemsByMonthYear(
                      calendarDays.map((day) => day.toMap()).toList());

              return Expanded(
                child: ListView.builder(
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

                  
                    // Build list of cards for each month
                    List<Widget> cards = (groupedItems[index]["days"]
                            as List<Map<String, dynamic>>)
                        .map((item) {
                      // Replace with your card widget creation logic
                      return const Card(
                        color: Colors.white,
                        elevation: 5,
                        shadowColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        margin: EdgeInsets.all(5),
                      );
                    }).toList();

                    return Column(
                      children: [
                        header,
                        SizedBox(
                          height: 300,
                          child: AnimationLimiter(
                            child: GridView.count(
                              physics: const NeverScrollableScrollPhysics(),    //so we won't scroll the days only the big list with the months
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
                ),
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
