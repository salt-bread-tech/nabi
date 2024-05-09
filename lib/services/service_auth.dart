import 'package:doctor_nyang/services/urls.dart';
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

