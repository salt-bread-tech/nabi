import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> login(String id, String password, BuildContext context) async {
  final String baseUrl = "http://localhost:8080";
  final url = Uri.parse('$baseUrl/user/login');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'id': id,
        'password': password,
      }),
    );


    dynamic responseData = json.decode(response.body);

    if (responseData is int) {
      switch (responseData) {
        case 200:
          print('$id, 로그인 성공');
          Navigator.pushNamed(context, '/MyHomePage');
          break;
        case 400:
          print('로그인 실패: 아이디가 존재하지 않음');
          break;
        case 500:
          print('로그인 실패: 비밀번호 오류');
          break;
        default:
          print('알 수 없는 오류');
      }
    }
    print('응답 본문: ${response.body}');
  } catch (error) {
    print('네트워크 오류: $error');
  }
}


Future<void> register(String id, String password, String nickname, String birthDate, BuildContext context) async {
  final String baseUrl = "http://localhost:8080";
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
          Navigator.pushNamed(context, '/login');
          break;
        case 400:
          print('$id,$nickname,$birthDate,회원가입 실패: 아이디 중복');
          break;
        default:
          print('$id,$nickname,$birthDate,알 수 없는 오류');
      }
    }
  } catch (error) {
    print('$id,$nickname,$birthDate,네트워크 오류: $error');
  }
}
