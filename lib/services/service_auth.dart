import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'globals.dart' as globals;
import 'globals.dart';

Future<void> login(String id, String password, BuildContext context) async {
  final url = Uri.parse('$baseUrl/user/login');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': id, 'password': password}),
    );

    final responseData = int.tryParse(response.body);

    if (responseData != null) {
      globals.userId = responseData;
      print('로그인 성공: userID = ${globals.userId}');
      Navigator.pushNamed(context, '/MyHomePage');
    } else {
      print('오류: ${response.body}');
    }
  } catch (error) {
    print('네트워크 오류: $error');
  }
}



Future<void> register(String id, String password, String nickname, String birthDate, BuildContext context) async {
  final url = Uri.parse('$baseUrl/user/register');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'id': id,
        'password': password,
        'nickname': nickname,
        'birthDate': birthDate,
      }),
    );

    dynamic responseData = json.decode(response.body);

    if (responseData is int) {
      switch (responseData) {
        case 200:
          print('$id,$nickname,$birthDate, 회원가입 성공');
          Navigator.pushNamed(context, '/MyHomePage');
          break;
        case 100:
          print('$id,$nickname,$birthDate,회원가입 실패: 아이디 중복');
          break;
        case 400:
          print('$id,$nickname,$birthDate,유효하지 않은 BMR 값');
          break;
        case 500:
          print('$id,$nickname,$birthDate,유효하지 않은 BMI 값');
          break;
        default:
          print('$id,$nickname,$birthDate,알 수 없는 오류');
      }
    }
    //print('$id,$nickname,$birthDate,응답 본문: ${response.body}');
  } catch (error) {
    print('$id,$nickname,$birthDate,네트워크 오류: $error');
  }
}
