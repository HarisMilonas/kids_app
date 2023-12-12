import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'package:offline_app/componets/page_router.dart';
import 'package:offline_app/controllers/calendar_controller.dart';
import 'package:offline_app/models/calendar.dart';
import 'package:offline_app/screens/edit_day_page.dart';
import 'package:offline_app/styles/color_style.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int columnCount = 7;

  final AutoScrollController _controller = AutoScrollController();

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


              // value so the we navigate to the current month in the calendar     
              String indexToScroll = DateFormat('MMMM yyyy').format(
                  DateTime.now()); 

              // index to scroll
              int counter = 0;

              //check any value to match todays month and year
              for (var item in groupedItems) {
                if (item["month_year"] == indexToScroll) {
                  break;
                }
                counter++;
              }

              _controller.scrollToIndex(counter,
                  preferPosition: AutoScrollPosition.begin);

              return ListView.builder(
                controller: _controller,
                itemCount: groupedItems.length,
                itemBuilder: (context, index) {
                  String headerTitle = groupedItems[index]['month_year'];

                  // Build header for each month
                  Widget header = headerTile(headerTitle);

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

                    return dayCard(
                        context,
                        item,
                        isCurrentDate,
                        dayOfWeek,
                        dayOfMonth,
                        snapshot
                            .data!); // snapshot data because it contains all the dates
                  }).toList();

                  //insert empty items ahead of the days that the week is not starting
                  for (int i = 0; i < startingIndex; i++) {
                    cards.insert(0, Tooltip(message: "", child: Container()));
                  }

                  return AutoScrollTag(
                      key: ValueKey(index),
                      index: index,
                      controller: _controller,
                      child: daysGrid(header, cards));
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

  ListTile headerTile(String headerTitle) {
    return ListTile(
      tileColor: Colors.white,
      title: Center(
        child: Text(
          headerTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Column daysGrid(Widget header, List<Widget> cards) {
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
                    duration: const Duration(milliseconds: 400),
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
  }

  Tooltip dayCard(
      BuildContext context,
      Map<String, dynamic> item,
      bool isCurrentDate,
      String dayOfWeek,
      String dayOfMonth,
      List<Calendar> calendarDays) {
    double weekDuration = 0;
    // get the day hours
    double? dayDuration = double.tryParse(item["duration"] ?? '0');
    String hours;
    dayDuration != null || dayDuration != 0
        ? hours = (dayDuration! / 60).toStringAsFixed(1)
        : hours = '0';

    //get teh week hours of the day
    DateTime formatedDate = DateTime.parse(item['date']);
    List<String> weekDays = getWeekDates(formatedDate);
    for (Calendar day in calendarDays) {
      if (weekDays.contains(day.date)) {
        double? dbDuration = double.tryParse(day.duration ?? "0");
        if (dbDuration != 0) {
          dbDuration = dbDuration! / 60;
        }
        weekDuration += dbDuration!;
      }
    }

    return Tooltip(
      triggerMode: TooltipTriggerMode.longPress,
      message:
          "Μασελάκι: $hours ώρες σήμερα.\nΑυτή την εβδομάδα: ${weekDuration.toStringAsFixed(1)} ώρες.",
      child: GestureDetector(
        onTap: () {
          Navigator.of(context)
              .push(CustomPageRouter.fadeThroughPageRoute(EditDayPage(
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

  List<String> getWeekDates(DateTime date) {
    List<String> weekDates = [];

    // Get the Monday of the current week
    DateTime monday = date.subtract(Duration(days: date.weekday - 1));

    // Generate the dates for the entire week
    for (int i = 0; i < 7; i++) {
      DateTime currentDay = monday.add(Duration(days: i));
      String formattedDate =
          "${currentDay.year}-${currentDay.month.toString().padLeft(2, '0')}-${currentDay.day.toString().padLeft(2, '0')}";
      weekDates.add(formattedDate);
    }

    return weekDates;
  }
}
