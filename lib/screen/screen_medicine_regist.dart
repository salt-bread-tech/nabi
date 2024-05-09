import 'package:doctor_nyang/services/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import '../services/urls.dart';



//약 등록 api
Future<void> registMedicine(BuildContext context, int uid, String startDate,
    String medicineName, int once, int total, int daily, String dosage) async {
  final url = Uri.parse('$baseUrl/medicine/register');

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

  @override
  void initState() {
    super.initState();
    DateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        DateController.text = _formatDate(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('복용 일정 추가하기', style: TextStyle(fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Text('약 이름: ${widget.name}'),
            TextFormField(
              controller: onceController,
              decoration: InputDecoration(labelText: '1회 복용량'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: totalController,
              decoration: InputDecoration(labelText: '총 복용량'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: dailyController,
              decoration: InputDecoration(labelText: '하루 복용량'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
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
            TextFormField(
              controller: DateController,
              decoration: InputDecoration(labelText: '복용 시작 날짜'),
              readOnly: true,
              onTap: () => _selectDate(context),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final uid = userId;
                final String startDate = _formatDate(selectedDate);
                final String medicineName = widget.name;
                final int once = int.tryParse(onceController.text) ?? 0;
                final int total = int.tryParse(totalController.text) ?? 0;
                final int daily = int.tryParse(dailyController.text) ?? 0;
                final String dosage = _selectedDosage;

                print({
                  'uid': uid,
                  'startDate': startDate,
                  'medicineName': medicineName,
                  'once': once,
                  'total': total,
                  'daily': daily,
                  'dosage': dosage
                });

                await registMedicine(context, uid!, startDate, medicineName,
                    once, total, daily, dosage);
              },
              child: Text('등록하기'),
            ),
          ],
        ),
      ),
    );
  }
}
