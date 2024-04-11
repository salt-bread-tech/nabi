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
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  DateTime selectedDate = DateTime.now(); //




  String _formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  Future<void> _selectDate(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        final initDate=
            DateFormat('yyyy-MM-dd').parse('2000-01-01');

        return Container(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          color: Colors.white,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            dateOrder: DatePickerDateOrder.ymd,
            onDateTimeChanged: (picked) {
              if (picked != null && picked != selectedDate)
                setState(() {
                  selectedDate = picked;
                  birthDateController.text = _formatDate(picked);
                });
            },
            initialDateTime: initDate,
            minimumYear: 1900,
            maximumYear: DateTime.now().year,
            maximumDate: DateTime.now(),
          ),
        );
      },
    );
  }

  String _selectedGender = 'none';
  Widget genderButton(String gender) {
    bool isSelected = _selectedGender == gender;

    return Ink(
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFD3EAFF) : Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: isSelected ? const Color(0xFFD3EAFF) : Color(0xFFFBFBFB)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.0),
        onTap: () {
          setState(() {
            _selectedGender = gender;
          });
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal:65.0, vertical: 15.0),
          alignment: Alignment.center,
          child: Text(gender == 'male' ? '남성' : '여성'),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    Gender? _selectedGender;

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
                  labelText: '이메일',
                  hintText: 'email@example.com',
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
            //생년월일
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextFormField(
                  controller: birthDateController,
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
                    labelText: '생년월일',
                    hintText: _formatDate(selectedDate),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),
            Container(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  genderButton('male'), // 남성 버튼
                  SizedBox(width: 10), // 버튼 사이의 공간
                  genderButton('female'), // 여성 버튼
                ],
              ),
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
                    onPressed: ()async {
                      final nickname = nicknameController.text;
                      final id = emailController.text;
                      final password = passwordController.text;
                      final birthDate = _formatDate(selectedDate);

                      await register(nickname, id, password, birthDate, context);
                    },
                    child: Text(
                      '로그인',
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

