import 'dart:convert';
import 'package:doctor_nyang/services/urls.dart';
import 'package:http/http.dart' as http;

import 'globals.dart';

class Schedule {
  final int userUid;
  final String text;
  final DateTime date;

  Schedule({required this.userUid, required this.text, required this.date});

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      userUid: json["userUid"]["uid"],
      text: json['text'],
      date: DateTime.parse(json['date']),
    );
  }
}

Future<void> registerSchedule(int userUid, String text, String dateTime) async {
  final url = Uri.parse('$baseUrl/schedule/register');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json','Authorization': 'Bearer $token',},
    body: jsonEncode({
      'userUid': userUid,
      'text': text,
      'date': dateTime,
    }),
  );

  if (response.statusCode == 200) {
    print('등록 성공');
  } else if (response.statusCode == 500) {
    print('등록 실패: 찾고자 하는 유저가 없음');
  } else {
    print('알 수 없는 오류 발생: ${response.body}');
  }
}

Future<List<Schedule>> fetchSchedules(int userUid, String dateTime) async {
  final url = Uri.parse('$baseUrl/schedule/weekly-calendar');
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'userUid': userUid,
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
    Schedule schedule = Schedule(userUid: userUid, text: text, date: datetime);
    schedules.add(schedule);
  }
  schedules.sort((a, b) => a.date.compareTo(b.date));
  return schedules;
}
