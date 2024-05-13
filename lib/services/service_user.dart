import 'package:doctor_nyang/services/urls.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'globals.dart';


Future<void> updateBodyInfo({
  required String gender,
  required double height,
  required double weight,
  required String birth,
  required int age,
}) async {
  final url = Uri.parse('$baseUrl/user');
  final response = await http.put(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode(<String, dynamic>{
      'sex': gender,
      'height': height,
      'weight': weight,
      'birth': birth,
      'age': age,
    }),
  );

  if (response.statusCode == 200) {
    print('신체 정보 수정 성공');
  } else if (response.statusCode == 300) {
    print('정보 입력 실패: 유효하지 않은 키, 몸무게 값');
  } else if (response.statusCode == 400) {
    print('정보 입력 실패: 유효하지 않은 BMI 값');
  }
  else if (response.statusCode == 500) {
    print('정보 입력 실패: 유효하지 않은 BMR 값');
  }
  else {
    throw Exception('신체 정보 업데이트 실패');
  }
}