import 'dart:convert';

import 'package:doctor_nyang/assets/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/globals.dart';
import '../services/urls.dart';

Future<List<String>> getDosageList(String date) async {
  final String url = '$baseUrl/home/$date';

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
      Map<String, dynamic> data = json.decode(responseBody);
      List<String> dosages = List<String>.from(data['dosages'] ?? []);
      print('복용 일정 데이터 조회 성공(위젯)');
      return dosages;
    } else {
      print('복용 일정 데이터 조회 실패(위젯)');
      return [];
    }
  } catch (e) {
    print('네트워크 오류 $e');
    return [];
  }
}

class WidgetDosage extends StatefulWidget {
  final String datetime;

  WidgetDosage({
    required this.datetime,
  });

  @override
  _WidgetDosageState createState() => _WidgetDosageState();
}

class _WidgetDosageState extends State<WidgetDosage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.pastelBlue.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: FutureBuilder(
        future: getDosageList(widget.datetime),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
                margin: EdgeInsets.all(5),
                width: double.infinity,
                child: Text('의약품 복용 일정을 불러오는 중 입니다...'));
          } else if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data != null && (snapshot.data as List<String>).isNotEmpty) {
              List<String> dosages = snapshot.data as List<String>;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: dosages.map((dosage) {
                  return Container(
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    child: Text(
                      dosage,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              );
            } else {
              return Container(
                  margin: EdgeInsets.all(5),
                  width: double.infinity,
                  child: Text('등록된 의약품 복용 일정이 없습니다.'));
            }
          } else {
            return Container(
                margin: EdgeInsets.all(5),
                width: double.infinity,
                child: Text('의약품 복용 일정을 불러오는 중 오류가 발생했습니다.'));
          }
        },
      ),
    );
  }
}
