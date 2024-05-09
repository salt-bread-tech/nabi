import 'package:doctor_nyang/services/urls.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'globals.dart' as globals;
import 'globals.dart';


Map<String, dynamic> userInfo = {};
Map<String, dynamic> loginInfo = {};

Future<void> fetchUserInfo() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/user/show-info/${globals.userId}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
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
        globals.gender = userInfo['sex'];
        globals.age = userInfo['age'];
        print({globals.nickName});
        print('${globals.gender},${globals.age},$age,$gender');
      };
    } else {
      throw Exception('유저 정보 불러오기 실패');
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

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      switch (responseData['code']) {
        case 'SU': // 로그인 성공
          print('로그인 성공: 토큰 = ${responseData['token']}');
          // 전역 변수나 저장소에 토큰 저장
            globals.token = responseData['token'];

          //await saveToken(responseData['token']);
          Navigator.pushNamed(context, '/MyHomePage');
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
      }
    } else {
      print('서버 에러: HTTP 상태 코드 ${response.statusCode}');
    }
  } catch (error) {
    print('네트워크 오류: $error');
  }
  return false;
}
