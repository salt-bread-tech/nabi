import 'package:doctor_nyang/services/globals.dart';
import 'package:doctor_nyang/widgets/widget_custom_textFormField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import '../services/urls.dart';



class MedicineRegist extends StatefulWidget {
  final String name;

  MedicineRegist({required this.name});

  @override
  _MedicineRegistState createState() => _MedicineRegistState();
}

class _MedicineRegistState extends State<MedicineRegist> {

  String _selectedDosage = 'none';
  Widget DosageButton(String gender) {
    bool isSelected = _selectedDosage == gender;

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
            _selectedDosage = gender;
          });
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 65.0, vertical: 15.0),
          alignment: Alignment.center,
          child: Text(gender == '식후' ? '식전' : '식후'),
        ),
      ),
    );
  }


  DateTime selectedDate = DateTime.now();
  TextEditingController DateController = TextEditingController();
  TextEditingController onceController = TextEditingController();
  TextEditingController totalController = TextEditingController();
  TextEditingController dailyController = TextEditingController();
  //TextEditingController dosageController = TextEditingController();

  String dateError = '';
  String onceError = '';
  String totalError = '';
  String dailyError = '';
  String dosageError = '';


  void validateFields() {
    setState(() {
      dateError = DateController.text.isEmpty ? '날짜를 선택해주세요' : '';
      onceError = onceController.text.isEmpty ? '1회 복용량을 입력해주세요.' : '';
      totalError = totalController.text.isEmpty ? '총 복용량을 입력해주세요.' : '';
      dailyError = dailyController.text.isEmpty ? '하루 복용량을 입력해주세요.' : '';
    });
  }
  void validateDosage() {
    if (_selectedDosage == 'none') {
      setState(() {
        dosageError = '복용 방법을 선택해주세요.';
      });
    } else {
      setState(() {
        dosageError = '';
      });
    }
  }


  Future<void> registMedicine(BuildContext context, int uid, String startDate,
      String medicineName, int once, int total, int daily, String dosage) async {
    final url = Uri.parse('$baseUrl/medicine');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json','Authorization': 'Bearer $token',},
        body: json.encode({
          'uid': uid,
          'startDate': startDate,
          'medicineName': medicineName,
          'once': once,
          'total': total,
          'daily': daily,
          'dosage': dosage,
        }),
      );

      final responseData = json.decode(response.body);

      if (responseData is int) {
        switch (responseData) {
          case 200:
            print('약물 등록 성공');
            Navigator.pushNamed(context, '/DosageSchedule');
            break;
          case 100:
            print('등록 실패: 유저 정보를 찾을 수 없음');
            break;
          case 300:
            print('등록 실패: 처방전 정보를 찾을 수 없음');
            break;
          default:
            print('알 수 없는 오류');
        }
      }
    } catch (error) {
      print('네트워크 오류: $error');
    }
  }

  Future<void> medicineRegister() async {
    validateFields();
    validateDosage();

    if (dateError == '' && onceError == '' && totalError == '' && dailyError == '' &&
        dosageError == '') {
      final uid = userId;
      final String startDate = _formatDate(selectedDate);
      final String medicineName = widget.name;
      final int? once = int.tryParse(onceController.text);
      final int? total = int.tryParse(totalController.text);
      final int? daily = int.tryParse(dailyController.text);
      final String dosage = _selectedDosage;

      await registMedicine(context, uid!, startDate, medicineName,
          once!, total!, daily!, dosage);
    }
  }


  @override
  void initState() {
    super.initState();
    DateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  Future<void> _selectDate(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        final initDate = selectedDate;  // Use the current `selectedDate` directly, which is already a DateTime object

        return Container(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          color: Colors.white,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            dateOrder: DatePickerDateOrder.ymd,
            onDateTimeChanged: (picked) {
              if (picked != null && picked != selectedDate) {
                setState(() {
                  selectedDate = picked;
                  DateController.text = DateFormat('yyyy-MM-dd').format(picked);
                });
              }
            },
            initialDateTime: initDate,
            minimumYear: 1900,
            maximumYear: 2100,
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('복용 일정 추가하기', style: TextStyle(fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('약 이름: ${widget.name}'),
            SizedBox(height: 10),
            Text('1회 복용량'),
            SizedBox(height: 5),
            CustomTextFormField(
              controller: onceController,
              keyboardType: TextInputType.number,
              hintText: '1회 복용량을 입력해주세요',
            ),
            SizedBox(height: 10),
            Text('총 복용량'),
            SizedBox(height: 5),
            CustomTextFormField(
              controller: totalController,
              keyboardType: TextInputType.number, hintText: '총 복용량을 입력해주세요',
            ),
            SizedBox(height: 10),
            Text('하루 복용량'),
            SizedBox(height: 5),
            CustomTextFormField(
              controller: dailyController,
              keyboardType: TextInputType.number,
              hintText: '하루 복용량을 입력해주세요',
            ),
            SizedBox(height: 20),
            Text('복용 방법'),
            SizedBox(height: 5),
            Container(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DosageButton('식후'),
                  SizedBox(width: 10),
                  DosageButton('식전'),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text('복용 시작 날짜'),
            SizedBox(height: 5),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: CustomErrorTextFormField(
                  controller: DateController,
                  hintText: '날짜를 선택해주세요',
                  keyboardType: TextInputType.number,
                  errorText: dateError.isEmpty ? null : dateError,
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
                    onPressed: medicineRegister,
                    child: Text(
                      '등록하기',
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
