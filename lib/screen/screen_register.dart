import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/globals.dart';
import '../services/urls.dart';
import '../widgets/widget_custom_textFormField.dart';
import 'package:http/http.dart' as http;

enum Gender { male, female }

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool isIdDuplicated = false;
  bool isPasswordConfirmed = true;
  bool isInvalidBMR = false; // BMR
  bool isInvalidBMI = false; // BMI

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController confirmPWController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  DateTime selectedDate = DateTime.now();

  String nicknameError = '';
  String idError = '';
  String passwordError = '';
  String confirmPasswordError = '';
  String birthDateError = '';
  String genderError = '';
  String heightError = '';
  String weightError = '';


  void validateFields() {
    setState(() {
      nicknameError = nicknameController.text.isEmpty ? '닉네임을 입력해주세요.' : '';
      idError = emailController.text.isEmpty ? '아이디를 입력해주세요.' : '';
      passwordError = passwordController.text.isEmpty ? '비밀번호를 입력해주세요.' : '';
      confirmPasswordError =
      confirmPWController.text.isEmpty ? '비밀번호 확인을 입력해주세요.' : '';
      birthDateError = birthDateController.text.isEmpty ? '생년월일을 입력해주세요.' : '';
      genderError = genderController.text.isEmpty ? '성별을 선택해주세요.' : '';
      heightError = heightController.text.isEmpty ? '키를 입력해주세요.' : '';
      weightError = weightController.text.isEmpty ? '몸무게를 입력해주세요.' : '';
    });
  }

  void validateGender() {
    if (_selectedGender == 'none') {
      setState(() {
        genderError = '성별을 선택해주세요.';
      });
    } else {
      setState(() {
        genderError = '';
      });
    }
  }


  Future<bool> register(String nickname, String id, String password,
      String birthDate, String gender, double height, double weight, int age,
      BuildContext context) async {
    final url = Uri.parse('$baseUrl/user/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json',
        },
        body: json.encode({
          'nickname': nickname,
          'id': id,
          'password': password,
          'birthDate': birthDate,
          'sex': gender,
          'height': height,
          'weight': weight,
          'age': age,
        }),
      );

      final responseData = json.decode(response.body);
      switch (responseData['code']) {
        case 'SU': //회원가입 성공
          print('회원가입 성공: ${responseData['message']}');
          Navigator.pushNamed(context, '/login');
          return true;

        case 'DI': // 아이디 중복
          print('아이디 중복: ${responseData['message']}');
          setState(() {
            isIdDuplicated = true;
          });
          break;

        case 'CF': // 올바른 형식이 아님
          print('올바른 형식이 아님: ${responseData['message']}');
          setState(() {
            isInvalidBMR = true;
            isInvalidBMI = true;
          });
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
        print('회원가입 실패: ${responseData['message']}');
        return false;
      }
    } catch (e) {
      print('오류: $e');
      return false;
    }
    return false;
  }

  Future<void> attemptRegister() async {
    validateFields();
    validateGender();

    if (nicknameError == '' && idError == '' && passwordError == '' && confirmPasswordError == '' &&
        birthDateError == '' && heightError == '' && weightError == '') {
      final nickname = nicknameController.text;
      final id = emailController.text;
      final password = passwordController.text;
      final birthDate = birthDateController.text;
      final sex = _selectedGender;
      final height = double.tryParse(heightController.text);
      final weight = double.tryParse(weightController.text);
      final age = calculateAge(selectedDate);

      await register(nickname, id, password, birthDate, sex, height!, weight!, age, context);
    }
  }

//닉네임
  Widget _buildNicknameField() {
    return CustomErrorTextFormField(
      controller: nicknameController,
      keyboardType: TextInputType.name,
      hintText: '닉네임을 입력해주세요',
      errorText: nicknameError.isEmpty ? null : nicknameError,
    );
  }

  //아이디
  Widget _buildIdField() {
    return CustomErrorTextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      hintText: '아이디를 입력해주세요',
      errorText: isIdDuplicated ? '중복된 아이디입니다.' : (idError.isNotEmpty ? idError : null),
    );
  }


  //비번
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('비밀번호', style: TextStyle(fontSize: 12)),
        SizedBox(height: 5),
        CustomErrorTextFormField(
          controller: passwordController,
          keyboardType: TextInputType.visiblePassword,
          hintText: '비밀번호를 입력해주세요',
          isPassword: true,
          errorText: passwordError.isEmpty ? null : passwordError,

        ),
        SizedBox(height: 10),
        Text('비밀번호 확인', style: TextStyle(fontSize: 12)),
        SizedBox(height: 5),
        CustomErrorTextFormField(
          controller: confirmPWController,
          keyboardType: TextInputType.visiblePassword,
          hintText: '비밀번호 확인',
          isPassword: true,
          errorText: isPasswordConfirmed ? null : '비밀번호가 일치하지 않습니다.',
        ),
      ],
    );
  }
  //키, 몸무게
  Widget _buildBMIField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('키', style: TextStyle(fontSize: 12)),
        SizedBox(height: 5),
        CustomErrorTextFormField(
          controller: heightController,
          keyboardType: TextInputType.number,
          hintText: '키를 입력해주세요 (cm)',
          suffixText: 'cm',
          errorText: isInvalidBMR ? '키를 확인해주세요' : (heightError.isNotEmpty ? heightError : null),
        ),
        SizedBox(height: 10),
        Text('몸무게', style: TextStyle(fontSize: 12)),
        SizedBox(height: 5),
        CustomErrorTextFormField(
          controller: weightController,
          keyboardType: TextInputType.number,
          hintText: '몸무게를 입력해주세요 (kg)',
          suffixText: 'kg',
          errorText: isInvalidBMI ? '몸무게를 확인해주세요' : (weightError.isNotEmpty ? weightError : null),
        ),
      ],
    );
  }

  //생년월일
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

  //나이
  int calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (birthDate.month > currentDate.month ||
        (birthDate.month == currentDate.month && birthDate.day > currentDate.day)) {
      age--;
    }
    return age;
  }

  //성별
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
          padding: EdgeInsets.symmetric(horizontal: 65.0, vertical: 15.0),
          alignment: Alignment.center,
          child: Text(gender == '남성' ? '남성' : '여성'),
        ),
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    passwordController.addListener(_validatePassword);
    confirmPWController.addListener(_validatePassword);
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPWController.dispose();
    super.dispose();
  }
  void _validatePassword() {
    setState(() {
      isPasswordConfirmed = passwordController.text == confirmPWController.text;
    });
  }


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
            SizedBox(height: 30),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('닉네임', style: TextStyle(fontSize: 12)),
                SizedBox(height: 5),
                _buildNicknameField(),
                SizedBox(height: 15),
                Text('아이디', style: TextStyle(fontSize: 12)),
                SizedBox(height: 5),
                _buildIdField(),
                SizedBox(height: 15),
                _buildPasswordField(),
                SizedBox(height: 15),
                Text('생년월일', style: TextStyle(fontSize: 12)),
                SizedBox(height: 5),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: CustomErrorTextFormField(
                      controller: birthDateController,
                      hintText: '생년월일',
                      keyboardType: TextInputType.number,
                      errorText: birthDateError.isEmpty ? null : birthDateError,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                Text('성별', style: TextStyle(fontSize: 12)),
                SizedBox(height: 5),
              ],
            ),
            Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        genderButton('남성'),
                        SizedBox(width: 10),
                        genderButton('여성'),
                      ],
                    ),
                    if (genderError.isNotEmpty) Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '성별을 선택해주세요',
                        style: TextStyle(fontSize: 12,color: Colors.red),
                      ),
                    ),
                  ],
                )


            ),
            SizedBox(height: 15),
            _buildBMIField(),
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
                    onPressed: attemptRegister,
                    child: Text(
                      '회원가입',
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

