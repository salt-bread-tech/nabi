import 'dart:convert';
import 'package:doctor_nyang/assets/theme.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/globals.dart';
import '../services/urls.dart';

List<dynamic> dosages = [];

Future<void> getDosageList(String date) async {
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

      List<dynamic> _dosages = json.decode(responseBody)['dosages'];
      dosages = _dosages;
      print('복용 일정 데이터 조회 성공(위젯)');
    } else {
      print('복용 일정 데이터 조회 실패(위젯)');
    }
  } catch (e) {
    print('네트워크 오류 $e');
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
            if (dosages.isNotEmpty) {
              return Column(
                children: dosages.map((prescription) {
                  String name = prescription['name'] ?? 'Unknown';
                  int times = prescription['times'] ?? -1;
                  int dosageMethod = prescription['dosage'] ?? -1;

                  String timesText;
                  switch (times) {
                    case 0:
                      timesText = '아침';
                      break;
                    case 1:
                      timesText = '점심';
                      break;
                    case 2:
                      timesText = '저녁';
                      break;
                    case 3:
                      timesText = '자기 전';
                      break;
                    default:
                      timesText = '알 수 없음';
                      break;
                  }

                  String dosageText;
                  switch (dosageMethod) {
                    case 0:
                      dosageText = '식전';
                      break;
                    case 1:
                      dosageText = '식중';
                      break;
                    case 2:
                      dosageText = '식후';
                      break;
                    case 3:
                      dosageText = '상관 없음';
                      break;
                    default:
                      dosageText = '알 수 없음';
                      break;
                  }

                  return Container(
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name),
                        Spacer(),
                        Text(
                          timesText,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        if (times != 3) ...[
                          Text(' '),
                          Text(
                            dosageText,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
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
