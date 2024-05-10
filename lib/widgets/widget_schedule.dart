import 'dart:convert';

import 'package:doctor_nyang/assets/theme.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import '../services/globals.dart';
import '../services/urls.dart';

class WidgetSchedule extends StatefulWidget {
  final int time;
  final int minute;
  final String content;
  final bool isDone;

  WidgetSchedule({
    required this.time,
    required this.minute,
    required this.content,
    required this.isDone,
  });

  @override
  _WidgetScheduleState createState() => _WidgetScheduleState();
}

class _WidgetScheduleState extends State<WidgetSchedule> {
  final Map<int, WidgetSchedule> schedules = {
    0: WidgetSchedule(
      time: 13,
      minute: 20,
      content: '밥먹기',
      isDone: false,
    ),
  };

  Future<void> fetchSchedule() async {
    final String url = '$baseUrl/schedule/$userId';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        String responseBody = utf8.decode(response.bodyBytes);
        List<dynamic> schedules = json.decode(responseBody);

        for (int i = 0; i < schedules.length; i++) {
          schedules[schedules[i]['time']] = WidgetSchedule(
            time: schedules[i]['time'],
            minute: schedules[i]['minute'],
            content: schedules[i]['content'],
            isDone: schedules[i]['isDone'],
          );
        }
      } else {
        throw Exception('Failed to load schedule');
      }
    } catch (e) {
      print('error: $e');
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
      child: Column(
          children: schedules.isEmpty
              ? [Container(width: double.infinity, child: Text('등록된 일정이 없습니다.'))]
              : schedules.entries.map((entry) {
                  WidgetSchedule schedule = entry.value;
                  return Container(
                    margin: EdgeInsets.all(5),
                    width: double.infinity,
                    child: Text(
                        '${schedule.time}:${schedule.minute.toString().padLeft(2, '0')} | ${schedule.content}',
                        style: schedule.isDone
                            ? TextStyle(
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Colors.grey)
                            : TextStyle(color: Colors.black)),
                  );
                }).toList()),
    );
  }
}
