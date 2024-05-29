import 'dart:convert';

import 'package:doctor_nyang/services/urls.dart';
import 'package:http/http.dart' as http;

import 'globals.dart';

Future<void> getWidgetOrder() async {
  final url = Uri.parse('$baseUrl/home/widget');

  final response = await http.get(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    print('위젯 순서 조회 성공');
    Map<String, dynamic> responseData =
        json.decode(utf8.decode(response.bodyBytes));
    usedWidget = responseData['used'];
    unusedWidget = responseData['unused'];

    print('usedWidget: $usedWidget');
    print('unusedWidget: $unusedWidget');
  } else {
    throw Exception('위젯 순서 조회 실패');
  }
}

Future<void> editWidgetOrder() async {
  final url = Uri.parse('$baseUrl/home/widget');

  final response = await http.put(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, dynamic>{
      'used': usedWidget,
      'unused': unusedWidget,
    }),
  );

  if (response.statusCode == 200) {
    print('위젯 순서 수정 성공');
  } else {
    throw Exception('위젯 순서 수정 실패');
  }
}
