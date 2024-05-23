import 'package:doctor_nyang/services/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/urls.dart';
import '../widgets/widget_weeklyCalendar2.dart';
import '../widgets/widget_weekly_calendar.dart';


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
    final String url = '$baseUrl/dosage';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
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
      print('Token: $token');
      print('Formatted Date: $formattedDate');
    }
  }

  //일정 토글
  Future<void> toggleDosage(int medicineId, String date, int times) async {
    final String url = '$baseUrl/dosage';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({
          'medicineId': medicineId,
          'date': date,
          'times': times,
        }),
      );

      if (response.statusCode == 200) {
        fetchDosageSchedule();
        print('복용 일정 완료(미완료) 토글링 성공');
        print('$medicineId $times');
      } else {
        print('복용 일정 변경 실패');
      }
    } catch (e) {
      print('네트워크 오류 $e');
    }
  }


  Future<void> deleteMedicine(int dosageId) async {
    final url = Uri.parse('$baseUrl/dosage/$dosageId');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        print('약물 일정 삭제 성공');
        fetchDosageSchedule();
      } else {
        print('약물 일정 삭제 실패');
      }
    } catch (e) {
      print('네트워크 오류: $e');
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

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.all(20),
          elevation: 0,
          title: Text('의약품 복용 일정 추가하기',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,),
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 130,
                  height: 100,
                  decoration: BoxDecoration(
                    //color: Color(0xFFE0F0FF),
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/MedicineRegister');
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Iconsax.edit, size: 20),
                        SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text('직접 작성하기'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  width: 130,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/MedicineSearch');
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Iconsax.search_normal, size: 20),
                        SizedBox(height: 10),
                        Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text('검색하기'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _handleDateChange(DateTime newDate) {
    setState(() {
      selectedDate = newDate;
      fetchDosageSchedule();
    });
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


  Map<String, List<dynamic>> categorizeDosage() {
    Map<String, List<dynamic>> categorizedSchedule = {
      '아침': [],
      '점심': [],
      '저녁': [],
    };

    for (var dosage in dosageSchedule) {
      int timeValue = timesToInt[dosage['times']] ?? -1;
      if ([0, 1].contains(timeValue)) {
        categorizedSchedule['아침']?.add(dosage);
      } else if ([2, 3].contains(timeValue)) {
        categorizedSchedule['점심']?.add(dosage);
      } else if ([4, 5].contains(timeValue)) {
        categorizedSchedule['저녁']?.add(dosage);
      }
    }

    return categorizedSchedule;
  }


  @override
  Widget build(BuildContext context) {
    var categorizedSchedule = categorizeDosage();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '$nickName님의 복용 일정',
          style: TextStyle(color: Colors.black, fontSize: 17),
          textAlign: TextAlign.center,
        ),
        iconTheme: IconThemeData(color: Colors.black),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showDialog,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            WidgetCalendar2(onDateSelected: _handleDateChange),
            Expanded(
              child: ListView(
                children: [
                  if (categorizedSchedule['아침']!.isNotEmpty)
                    timeSection('아침', categorizedSchedule['아침']!),
                  SizedBox(height: 10),
                  if (categorizedSchedule['점심']!.isNotEmpty)
                    timeSection('점심', categorizedSchedule['점심']!),
                  SizedBox(height: 10),
                  if (categorizedSchedule['저녁']!.isNotEmpty)
                    timeSection('저녁', categorizedSchedule['저녁']!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget timeSection(String title, List<dynamic> schedule) {
    if (schedule.isEmpty) {
      return SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...schedule.map((dosage) =>
            Slidable(
              key: Key(dosage['dosageId'].toString()),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) => deleteMedicine(dosage['dosageId']),
                    backgroundColor: Color(0xFFFF5050),
                    foregroundColor: Colors.white,
                    icon: Iconsax.trash,
                  ),
                ],
              ),
              child: Card(
                shadowColor: Colors.black,
                elevation: 0,
                color: dosage['medicineTaken'] ? Color(0xFFE3F2FF) : Color(
                    0xFFF1F1F1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Text('${dosage['medicineName']}'),
                  subtitle: Text(dosage['times']),
                  trailing: Icon(
                    dosage['medicineTaken'] ? Icons.check : Icons.check,
                    color: dosage['medicineTaken'] ? Color(0xFF6696DE) : Colors
                        .grey,
                  ),
                  onTap: () async {
                    int timeValue = timesToInt[dosage['times']] ?? -1;
                    await toggleDosage(
                        dosage['medicineId'], dosage['date'], timeValue);
                    print('medicineId: ${dosage['medicineId']}, date: ${dosage['date']}, times: $timeValue');
                  },
                ),
              ),
            )).toList(),
      ],
    );
  }
}