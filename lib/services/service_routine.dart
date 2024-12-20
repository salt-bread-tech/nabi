import 'package:doctor_nyang/services/urls.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'globals.dart';


Future<void> registerDailyRoutine({
  required String routineName,
  required int maxPerform,
  required String startDate,
  required String colorCode,
  required int maxTerm,
}) async {
  final url = Uri.parse('$baseUrl/routine');
  final response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, dynamic>{
      'name': routineName,
      'maxPerform': maxPerform,
      'date': startDate,
      'colorCode': colorCode,
      'maxTerm': maxTerm,
    }),
  );

  if (response.statusCode == 200) {
    print('루틴 등록 성공');
  } else if (response.statusCode == 400) {
    print('사용자 정보를 찾을 수 없음');
  } else {
    throw Exception('루틴 등록 실패');
  }
}
