import 'package:flutter/material.dart';
import '../services/service_auth.dart';
import '../widgets/widget_custom_textFormField.dart';




class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool showError = false;

  void attemptLogin() async {
    final id = emailController.text;
    final password = passwordController.text;
    bool success = await login(id, password, context);
    if (!success) {
      setState(() {
        showError = true;
      });
    } else {
      setState(() {
        showError = false;
      });
    }
  }

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
                  '로그인하기',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
              ],
            ),
            SizedBox(height: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Text('아이디', style: TextStyle(fontSize: 12)),
                SizedBox(height: 5),
                CustomTextFormField(
                  keyboardType: TextInputType.emailAddress,
                  hintText: '아이디를 입력해주세요',
                  controller: emailController,
                  isPassword: false,
                ),
                //Text('비밀번호', style: TextStyle(fontSize: 12)),
                SizedBox(height: 7),
                CustomTextFormField(
                  hintText: '비밀번호를 입력해주세요',
                  controller: passwordController,
                  keyboardType: TextInputType.visiblePassword,
                  isPassword: true,
                )
              ],
            ),
            SizedBox(height: 10),
            // Error message
            Visibility(
              visible: showError,
              child: Text('아이디 또는 비밀번호를 다시 확인하세요.', style: TextStyle(color: Colors.red,fontSize: 12)),
            ),
            SizedBox(height: 15),
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
                      attemptLogin();
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
                    fontSize: 14.0,
                    color: Colors.grey[800],
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
