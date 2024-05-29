import 'dart:convert';

import 'package:doctor_nyang/assets/theme.dart';
import 'package:flutter/material.dart';
import 'package:timelines/timelines.dart';

import 'package:http/http.dart' as http;
import '../services/globals.dart';
import '../services/urls.dart';

class Schedule {
  final String text;
  final DateTime date;
  final bool isDone;

  Schedule({required this.text, required this.date, this.isDone = false});

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      text: json['text'],
      date: DateTime.parse(json['date']).toUtc(),
    );
  }
}

Future<List<Schedule>> fetchSchedule(String dateTime) async {
  try {
    String datetime = dateTime.toString().substring(0, 10);
    final url = Uri.parse('$baseUrl/schedule/$datetime');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<Schedule> schedules = [];
      final decodedBody = utf8.decode(response.bodyBytes);
      final data = json.decode(decodedBody);

      if (data is int) {
        throw Exception('조회 실패 ${response.statusCode}');
      }

      for (var jsonItem in data[dateTime]) {
        String text = jsonItem['text'];
        DateTime datetime = DateTime.parse(jsonItem['date']);
        bool isDone = DateTime.now().isAfter(datetime) ? true : false;
        Schedule schedule = Schedule(text: text, date: datetime, isDone: isDone);
        schedules.add(schedule);
      }
      schedules.sort((a, b) => a.date.compareTo(b.date));

      return schedules;
    } else {
      throw Exception('Failed to load schedule');
    }
  } catch (e) {
    print('error: $e');
    return []; // Return an empty list on error
  }
}


class WidgetSchedule extends StatefulWidget {
  final String datetime;
  final bool isWidget;

  WidgetSchedule({
    required this.datetime,
    required this.isWidget,
  });

  @override
  _WidgetScheduleState createState() => _WidgetScheduleState();
}

class _WidgetScheduleState extends State<WidgetSchedule> {

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.isWidget ? AppTheme.pastelBlue.withOpacity(0.5) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
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
                    '${schedule.date.hour.toString().padLeft(2, '0')}:${schedule.date.minute.toString().padLeft(2, '0')} | ${schedule.text}',
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
          return Container(
            margin: EdgeInsets.all(5),
            width: double.infinity,
            child: Text('일정을 불러오는 중입니다...'),
          );
        },
      ),
    );
  }
}
