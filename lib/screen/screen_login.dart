import 'package:flutter/material.dart';
import '../services/service_auth.dart';
import '../widgets/widget_custom_textFormField.dart';

class Login extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 100),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '닥터냥 로그인하기',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            SizedBox(height: 20),
            Column(
              children: <Widget>[
                CustomTextFormField(
                  keyboardType: TextInputType.emailAddress,
                  labelText: '이메일',
                  hintText: 'example@gmail.com',
                  controller: emailController,
                  isPassword: false,
                ),
                SizedBox(height: 20),
                CustomTextFormField(
                  labelText: '비밀번호',
                  hintText: '비밀번호 입력',
                  controller: passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  isPassword: true,
                )
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 85,
                  height: 35,
                  child: TextButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFE0F0FF),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: () async {
                      final id = emailController.text;
                      final password = passwordController.text;
                      await login(id, password, context);
                    },
                    child: Text(
                      '로그인',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                )
              ],
            ),
            Spacer(),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                  children: <TextSpan>[
                    TextSpan(text: '계정이 없으신가요? '),
                    TextSpan(
                        text: '회원가입',
                        style: TextStyle(color: Color(0xFF2144FF)),
                    ),
                    TextSpan(text: '하기'),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
