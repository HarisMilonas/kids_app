import 'dart:convert';

class Calendar {
  int? id;
  String date;
  String? duration; // total duration
  Map<String, dynamic>? details; // detailed hours in the day
  String? comments;

  Calendar(
      {this.id,
      required this.date,
      this.duration,
      this.details,
      this.comments});

  factory Calendar.fromMap(Map<String, dynamic> map) {
    return Calendar(
        id: map['id'],
        date: map["date"],
        duration: map['duration'],
        details: map['details'] != null ? jsonDecode(map['details']) : null,
        comments: map["comments"]);
  }

    Map<String, dynamic> toMap() => {
        "id": id,
        "date": date,
        "duration": duration,
        "details": jsonEncode(details),
        "comments": comments,
      };
}
