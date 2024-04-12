import 'package:doctor_nyang/screen/screen_register2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/service_auth.dart'; //DateFormat

enum Gender { male, female }

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}
class _RegisterState extends State<Register> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController confirmPWController = TextEditingController();


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView( // 키보드가 올라왔을 때 오버플로우 방지
        padding: EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 100,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '회원가입하기',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 3,
                    blurRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextFormField(
                controller: nicknameController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color(0xFF98CBFA),
                      )),
                  labelText: '닉네임',
                  hintText: '냥냥이',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 3,
                    blurRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white),),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color(0xFF98CBFA),
                      )),
                  labelText: '아이디',
                  hintText: '아이디를 입력해주세요',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 3,
                    blurRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color(0xFF98CBFA),
                      )),
                  labelText: '비밀번호',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 3,
                    blurRadius: 2,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: TextFormField(
                controller: confirmPWController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.white)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Color(0xFF98CBFA),
                      )),
                  labelText: '비밀번호 확인',
                  labelStyle: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 60,
                  height: 35,
                  child: TextButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE0F0FF),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: ()async {
                      final nickname = nicknameController.text;
                      final id = emailController.text;
                      final password = passwordController.text;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Register2(
                            nickname: nickname,
                            email : id,
                            password: password,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      '계속하기',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

