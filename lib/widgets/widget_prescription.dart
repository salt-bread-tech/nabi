import 'dart:convert';

import 'package:doctor_nyang/assets/theme.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import '../services/globals.dart';
import '../services/urls.dart';

List<dynamic> prescriptions = [];

Future<void> getPrescriptionList(String date) async {
  final String url = '$baseUrl/prescriptions/date/$date';

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
      List<dynamic> _prescriptions = json.decode(responseBody);
      prescriptions = _prescriptions;

      print('처방전 목록 조회 성공!');
    } else {
      print('처방전 목록 조회 실패');
    }
  } catch (e) {
    print('네트워크 오류 $e');
  }
}

class WidgetPrescription extends StatefulWidget {
  final String datetime;

  WidgetPrescription({
    required this.datetime,
  });

  @override
  _WidgetPrescriptionState createState() => _WidgetPrescriptionState();
}

class _WidgetPrescriptionState extends State<WidgetPrescription> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.pastelGreen.withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: FutureBuilder(
        future: getPrescriptionList(widget.datetime),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
                margin: EdgeInsets.all(5),
                width: double.infinity,
                child: Text('처방전을 불러오는 중입니다...'));
          } else if (!snapshot.hasData && prescriptions.isEmpty) {
            return Container(
                margin: EdgeInsets.all(5),
                width: double.infinity,
                child: Text('등록된 처방전이 없습니다.'));
          } else if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: prescriptions.map((prescription) {
                return Container(
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${prescription['name']}',
                        ),
                        Text(
                          '${prescription['date']}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        )
                      ],
                    ));
              }).toList(),
            );
          } else {
            return Container(
                margin: EdgeInsets.all(5),
                width: double.infinity,
                child: Text('처방전을 불러오는 중 오류가 발생했습니다.'));
          }
        },
      ),
    );
  }
}
