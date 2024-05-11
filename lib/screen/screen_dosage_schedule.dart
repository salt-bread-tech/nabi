import 'package:doctor_nyang/services/globals.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/urls.dart';


class DosageSchedule extends StatefulWidget {
  @override
  _DosageScheduleState createState() => _DosageScheduleState();
}

class _DosageScheduleState extends State<DosageSchedule> {
  late DateTime selectedDate;
  List<dynamic> dosageSchedule = [];

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    fetchDosageSchedule();
  }

  //일정 가져오기
  Future<void> fetchDosageSchedule() async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    final String url = '$baseUrl/medicine';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json','Authorization': 'Bearer $token',},
      );

      if (response.statusCode == 200) {
        String responseBody = utf8.decode(response.bodyBytes);
        List<dynamic> allSchedule = json.decode(responseBody);

        List<dynamic> todaySchedule = allSchedule.where((schedule) {
          String scheduleDate = schedule['date'];
          return scheduleDate == formattedDate;
        }).toList();

        setState(() {
          dosageSchedule = todaySchedule;
        });
      } else {
        print('복용 일정 조회 실패');
      }
    } catch (e) {
      print('네트워크 오류 $e');
    }
  }

  //일정 토글
  Future<void> toggleDosage(int userUid,int medicineId, String date,int times) async {
    final String url = '$baseUrl/dosage';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userUid': userId,
          'medicineId': medicineId,
          'date': date,
          'times': times,
        }),
      );

      if (response.statusCode == 200) {
        fetchDosageSchedule();
        print('복용 일정 완료(미완료) 토글링 성공');
      } else {
        print('복용 일정 변경 실패');
      }
    } catch (e) {
      print('네트워크 오류 $e');
    }
  }

//날짜 선택
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        fetchDosageSchedule();
      });
    }
  }

  Map<String, int> timesToInt = {
    '아침 식전': 0,
    '아침 식후': 1,
    '점심 식전': 2,
    '점심 식후': 3,
    '저녁 식전': 4,
    '저녁 식후': 5,
    '자기 전': 6,
    '공복': 7,
    '아침 식사': 8,
    '점심 식사': 9,
    '저녁 식사': 10,
    '간식': 11,
  };


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios), onPressed: () { Navigator.pushNamed(context, '/MyHomePage');},
        ),
        title: Text(
          '$nickName님의 복용 일정',
          style: TextStyle(color: Colors.black,fontSize: 17),
          textAlign: TextAlign.center,
        ),
        iconTheme: IconThemeData(color: Colors.black),
        actions: <Widget>[
          IconButton(
            icon: Icon(Iconsax.add),
            onPressed: () {
              Navigator.pushNamed(context, '/MedicineSearch');
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Text(
                DateFormat('yyyy년 MM월 dd일 EEEE').format(selectedDate),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: dosageSchedule.length,
                itemBuilder: (context, index) {
                  var dosage = dosageSchedule[index];
                  return Card(
                    shadowColor: Colors.black,
                    elevation: 0,
                    color: dosage['medicineTaken'] ? Color(0xFFD3EAFF) : Color(0xFFF1F1F1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text('${dosage['medicineName']}'),
                      subtitle: Text(dosage['times']),
                      trailing: Icon(
                        dosage['medicineTaken'] ? Icons.check : Icons.check,
                        color: dosage['medicineTaken'] ? Color(0xFF6696DE) : Colors.grey,
                      ),
                      onTap: () async {
                        int timeValue = timesToInt[dosage['times']] ?? -1;
                        await toggleDosage(userId!, dosage['medicineId'], dosage['date'], timeValue);
                        print('userId: $userId, medicineId: ${dosage['medicineId']}, date: ${dosage['date']}, times: $timeValue');
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
