import 'dart:convert';

import 'package:doctor_nyang/assets/theme.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import '../services/globals.dart';
import '../services/urls.dart';

class Schedule {
  final int userUid;
  final String text;
  final DateTime date;
  final bool isDone;

  Schedule(
      {required this.userUid,
      required this.text,
      required this.date,
      this.isDone = false});

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      userUid: json["userUid"]["uid"],
      text: json['text'],
      date: DateTime.parse(json['date']),
    );
  }
}

class WidgetSchedule extends StatefulWidget {
  final String datetime;

  WidgetSchedule({
    required this.datetime,
  });

  @override
  _WidgetScheduleState createState() => _WidgetScheduleState();
}

class _WidgetScheduleState extends State<WidgetSchedule> {
  String dateTIme = DateTime.now().toString().substring(0, 10);

  Future<List<Schedule>> fetchSchedule(String dateTime) async {
    {
      final url = Uri.parse('$baseUrl/schedule/weekly-calendar');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userUid': userId,
          'date': dateTime,
        }),
      );
      List<Schedule> schedules = [];
      final decodedBody = utf8.decode(response.bodyBytes);
      final data = json.decode(decodedBody);

      if (data is int) {
        throw Exception('조회 실패 ${response.statusCode}');
      }
      for (var jsonItem in data[dateTime]) {
        int userUid = jsonItem['userUid']['uid'];
        String text = jsonItem['text'];
        DateTime datetime = DateTime.parse(jsonItem['date']);
        bool isDone = DateTime.now().isAfter(datetime) ? true : false;
        Schedule schedule = Schedule(
            userUid: userUid, text: text, date: datetime, isDone: isDone);
        schedules.add(schedule);
      }

      schedules.sort((a, b) => a.date.compareTo(b.date));

      return schedules;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.pastelBlue.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      child: FutureBuilder<List<Schedule>>(
        future: fetchSchedule(widget.datetime.toString().substring(0, 10)),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isEmpty) {
            return Container(
                margin: EdgeInsets.all(5),
                width: double.infinity,
                child: Text('등록된 일정이 없습니다.'));
          } else if (snapshot.hasData) {
            return Column(
              children: snapshot.data!.map((schedule) {
                return Container(
                  margin: EdgeInsets.all(5),
                  width: double.infinity,
                  child: Text(
                    '${schedule.date.hour}:${schedule.date.minute.toString().padLeft(2, '0')} | ${schedule.text}',
                    style: schedule.isDone
                        ? TextStyle(
                            color: Colors.grey,
                            decorationColor: Colors.grey,
                            decoration: TextDecoration.lineThrough)
                        : TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}
