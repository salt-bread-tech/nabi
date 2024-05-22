import 'package:intl/intl.dart';

import 'package:doctor_nyang/main.dart';
import 'package:doctor_nyang/screen/screen_login.dart';
import 'package:doctor_nyang/services/urls.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../screen/screen_webtoon.dart';
import 'globals.dart' as globals;
import 'globals.dart';


Map<String, dynamic> userInfo = {};
Map<String, dynamic> loginInfo = {};

Future<void> fetchUserInfo() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${globals.token}',
      },
    );
    if (response.statusCode == 200) {
      String responseBody = utf8.decode(response.bodyBytes);
      userInfo = jsonDecode(responseBody);
      {
        globals.nickName = userInfo['nickName'];
        globals.id = userInfo['id'];
        globals.birth = userInfo['birth'];
        globals.height = userInfo['height'];
        globals.weight = userInfo['weight'];
        globals.gender = userInfo['gender'];
        globals.age = userInfo['age'];
        globals.bmr = userInfo['bmr'];
        print({globals.nickName});
      };
    } else {
      throw Exception('Failed to fetch user info: ${response.statusCode}');
    }
  } catch (error) {
    print('네트워크 오류: $error');
  }
}

Future<void> fetchDday() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/user/d-day'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${globals.token}',
      },
    );
    if (response.statusCode == 200) {
      String responseBody = utf8.decode(response.bodyBytes);
      loginInfo = jsonDecode(responseBody);
      {
        globals.dday = loginInfo['days'];
        print({globals.dday});
      };
    } else {
      throw Exception('Failed to fetch user info: ${response.statusCode}');
    }
  } catch (error) {
    print('네트워크 오류: $error');
  }
}

Future<bool> login(String id, String password, BuildContext context) async {
  //final String baseUrl = GlobalConfiguration().getString('baseUrl');
  final Uri url = Uri.parse('$baseUrl/user/login');

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': id, 'password': password}),
    );

      final responseData = json.decode(response.body);

      switch (responseData['code']) {
        case 'SU':
          print('로그인 성공: 토큰 = ${responseData['token']}');
            globals.token = responseData['token'];
          fetchUserInfo();
          fetchDday();
print('donetutorial : ${responseData['doneTutorial']}');
          if (responseData['doneTutorial'] == true) {
            print('myhomepage');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage()),
              ModalRoute.withName('/MyHomePage'),
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => WebtoonPage()),
              ModalRoute.withName('/webtoon'),
            );
          }
          return true;

        case 'SF': // 로그인 실패
          print('로그인 실패: ${responseData['message']}');
          break;

        case 'DBE': // 데이터베이스 에러
          print('데이터베이스 에러: ${responseData['message']}');
          break;

        case 'VF': // 올바르지 않은 요청
          print('올바르지 않은 요청: ${responseData['message']}');
          break;
        default:
          print('알 수 없는 응답 코드: ${responseData['code']}');
          break;
      }

//네트워크 요청 실패 시
    if (responseData['code'] != 'SU') {
      print('로그인 실패: ${responseData['message']}');
      return false;
    }
  } catch (e) {
    print('오류: $e');
    return false;
  }
  return false;
}


Future<void> logoutUser() async {

  try {
    final response = await http.post(
      Uri.parse('$baseUrl/user/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${globals.token}',
      },
    );

    if (response.statusCode == 200) {
      print("로그아웃 성공");

    } else {
      print("로그아웃 실패: ${response.statusCode}");
    }
  } catch (e) {
    print("네트워크 오류: $e");
  }
}


Future<void> withdrawUser() async {
  try {
    final response = await http.delete(
      Uri.parse('$baseUrl/user'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${globals.token}',
      },
    );

    if (response.statusCode == 200) {
      print("회원탈퇴 성공");
    } else {
      print("회원탈퇴 실패: ${response.statusCode}");
    }
  } catch (e) {
    print("네트워크 오류: $e");
  }
}
