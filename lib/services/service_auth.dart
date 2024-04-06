import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'globals.dart' as globals;
import 'globals.dart';


Map<String, dynamic> userInfo = {};

Future<void> fetchUserInfo() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/user/show-info/${globals.userId}'),
    );
    if (response.statusCode == 200) {
      userInfo = jsonDecode(response.body);
      {
        globals.nickName = userInfo['nickName'];
        globals.id = userInfo['id'];
        globals.birth = userInfo['birth'];
        globals.height = userInfo['height'];
        globals.weight = userInfo['weight'];
        print({globals.nickName});
      };
    } else {
      throw Exception('유저 정보 불러오기 실패');
    }
  } catch (error) {
    print('네트워크 오류: $error');
  }
}

// 로그인
Future<bool> login(String id, String password, BuildContext context) async {
  final url = Uri.parse('$baseUrl/user/login');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': id, 'password': password}),
    );

    final responseData = json.decode(response.body);

    if (responseData == 100) {
      print('로그인 실패: 존재하지 않는 아이디');
      return false;
    } else if (responseData == 300) {
      print('로그인 실패: 비밀번호 오류');
      return false;
    } else if (responseData == 400) {
      print('유저 정보를 찾을 수 없음');
      return false;
    } else {
      //로그인 성공 시 user 정보 저장
      globals.userId = responseData;
      print('로그인 성공: userID = ${globals.userId}');
      await fetchUserInfo();
      Navigator.pushNamed(context, '/MyHomePage');
      return true;
    }
  } catch (error) {
    print('네트워크 오류: $error');
    return false;
  }
}

Future<void> register(String id, String password, String nickname,
    String birthDate, BuildContext context) async {
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

