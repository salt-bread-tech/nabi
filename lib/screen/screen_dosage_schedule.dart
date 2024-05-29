import 'package:doctor_nyang/screen/screen_diet_schedule.dart';
import 'package:doctor_nyang/screen/screen_pre_forDosage.dart';
import 'package:doctor_nyang/services/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../assets/theme.dart';
import '../services/urls.dart';
import '../widgets/widget_calendar.dart';
import '../widgets/widget_delete.dart';
import '../widgets/widget_weeklyCalendar2.dart';
import '../widgets/widget_weekly_calendar.dart';

class DosageSchedule extends StatefulWidget {
  @override
  _DosageScheduleState createState() => _DosageScheduleState();
}

class _DosageScheduleState extends State<DosageSchedule> {
  late DateTime selectedDate;
  List<dynamic> dosageSchedule = [];
  final List<String> time = ['아침', '점심', '저녁', '취침전'];
  final List<String> medicineTakingTimes = ['식전', '식중', '식후', '상관 없음'];

  final GlobalKey<WidgetCalendarState> calendarKey = GlobalKey<WidgetCalendarState>();


  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    fetchDosageSchedule();
  }

  Future<void> fetchDosageSchedule() async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.toUtc());
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
print(todaySchedule);
        setState(() {
          dosageSchedule = todaySchedule;
        });
      } else {
        print('Failed to fetch dosage schedule');
      }
    } catch (e) {
      print('Network error: $e');
    }
  }

  Future<void> toggleDosage(int medicineId, String date, int times, int dosages) async {
    final String url = '$baseUrl/dosage/toggle';

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
          'dosages': dosages,
        }),
      );

      if (response.statusCode == 200) {
        fetchDosageSchedule();
        print('복용 일정 완료(미완료) 토글링 성공');
      } else {
        print('복용 일정 변경 실패');
      }
    } catch (e) {
      print('Network error: $e');
    }
  }

  Future<void> editMedicine({
    required int dosageId,
    required DateTime date,
    required int times,
    required int dosage,
  }) async {
    final url = Uri.parse('$baseUrl/dosage');
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode({
          'dosageId': dosageId,
          'date': formattedDate,
          'times': times,
          'dosages': dosage
        }),
      );

      if (response.statusCode == 200) {
        print('복용 일정 수정 성공');
        print('Sent data: {dosageId: $dosageId, date: $formattedDate, times: $times, dosage: $dosage}');
        fetchDosageSchedule();
      } else {
        print('복용 일정 수정 실패');
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Network error: $e');
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
        print('복용 일정 삭제 성공');
        fetchDosageSchedule();
      } else {
        print('복용 일정 삭제 실패');
      }
    } catch (e) {
      print('Network error: $e');
    }
  }

  void _selectDate() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return WidgetCalendarMonth(
          onDateSelected: (selectedDate) {
            Navigator.pop(context);
            _handleDateChange(selectedDate);
          },
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

  Map<int, String> timesToInt = {
    0: '아침',
    1: '점심',
    2: '저녁',
    3: '자기 전'
  };

  Map<int, String> medicineTakingTimesToInt = {
    0: '식전',
    1: '식중',
    2: '식후',
    3: '상관 없음'
  };

  Map<String, List<dynamic>> categorizeDosage() {
    Map<String, List<dynamic>> categorizedSchedule = {
      '아침': [],
      '점심': [],
      '저녁': [],
      '자기 전': [],
    };

    for (var dosage in dosageSchedule) {
      String timeKey = timesToInt[dosage['times']] ?? '알 수 없음';
      categorizedSchedule[timeKey]?.add(dosage);
    }

    return categorizedSchedule;
  }

  void editDosageModal(BuildContext context, dynamic dosage) {
    String selectedTime = timesToInt[dosage['times']] ?? '알 수 없음';
    int selectedDosage = dosage['dosage'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(bottom: 40, left: 20, right: 20, top: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: [
                      Text('복용 일정 수정하기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Spacer(),
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return WidgetCalendarMonth(
                                onDateSelected: (selectedDate) {
                                  Navigator.pop(context);
                                  setState(() {
                                    this.selectedDate = selectedDate;
                                  });
                                },
                              );
                            },
                          );
                        },
                        icon: Icon(Iconsax.calendar_2, size: 20),
                      ),
                      Text('${DateFormat('yyyy-MM-dd').format(selectedDate)}', style: TextStyle(fontSize: 15)),
                    ],
                  ),
                  SizedBox(width: 10),
                  Text('${dosage['medicineName']}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500)),
                  SizedBox(height: 20),
                  Text('복용 시간'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: time.map((e) {
                      return ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedTime = e;
                            // Automatically set dosage to "상관없음" if "취침전" is selected
                            if (selectedTime == '취침전') {
                              selectedDosage = medicineTakingTimes.indexOf('상관 없음');
                            }
                          });
                        },
                        child: Text(e, style: TextStyle(color: Colors.black, fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: selectedTime == e
                              ? AppTheme.pastelBlue
                              : Colors.grey[200],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20),
                  if (selectedTime != '취침전') ...[
                    Text('복용 방법'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: medicineTakingTimes.map((e) {
                        return ElevatedButton(
                          onPressed: () {
                            setState(() {
                              selectedDosage = medicineTakingTimes.indexOf(e);
                              print('Selected Dosage: $selectedDosage');
                            });
                          },
                          child: Text(e, style: TextStyle(color: Colors.black, fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: selectedDosage == medicineTakingTimes.indexOf(e)
                                ? AppTheme.pastelBlue
                                : Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    height: 55,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Color(0xFFEBEBEB),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        print('수정버튼눌럿을때: dosageId: ${dosage['dosageId']}, date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}, times: ${time.indexOf(selectedTime)}, dosage: $selectedDosage');
                        editMedicine(
                          dosageId: dosage['dosageId'],
                          date: selectedDate,
                          times: time.indexOf(selectedTime),
                          dosage: selectedDosage,
                        );
                        calendarKey.currentState?.updateSelectedDay(selectedDate);
                        Navigator.pop(context);
                      },
                      child: Text('저장하기'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
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
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrescriptionDosageScreen()),
              );
              setState(() {
                fetchDosageSchedule().then((_) {
                  setState(() {
                  });
                });
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            WidgetCalendar2(onDateSelected: _handleDateChange, calendarKey: calendarKey),
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
                  SizedBox(height: 10),
                  if (categorizedSchedule['자기 전']!.isNotEmpty)
                    timeSection('자기 전', categorizedSchedule['자기 전']!),
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
          child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...schedule.map((dosage) => Slidable(
          key: Key(dosage['dosageId'].toString()),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                flex: 1,
                onPressed: (context) => editDosageModal(context, dosage),
                backgroundColor: Colors.black12,
                foregroundColor: Colors.white,
                icon: Iconsax.edit,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              SlidableAction(
                onPressed: (context) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return DeleteConfirmDialog(
                        title: '삭제 확인',
                        content: '이 항목을 삭제하시겠습니까?',
                        onConfirm: () {
                          deleteMedicine(dosage['dosageId']);
                        },
                      );
                    },
                  );
                },
                backgroundColor: Color(0xFFFF5050),
                foregroundColor: Colors.white,
                icon: Iconsax.trash,
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
            ],
          ),
          child: Card(
            shadowColor: Colors.black,
            elevation: 0,
            color: dosage['medicineTaken'] ? Color(0xFFE3F2FF) : Color(0xFFF1F1F1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              title: Text('${dosage['medicineName']}'),
              subtitle: dosage['times'] == 3
                  ? Text('${timesToInt[dosage['times']]}')
                  : Text('${timesToInt[dosage['times']]}, ${medicineTakingTimesToInt[dosage['dosage']]}'),
              trailing: Icon(
                dosage['medicineTaken'] ? Icons.check : Icons.check,
                color: dosage['medicineTaken'] ? Color(0xFF6696DE) : Colors.grey,
              ),
              onTap: () async {
                await toggleDosage(dosage['medicineId'], dosage['date'], dosage['times'], dosage['dosage']);
                print('medicineId: ${dosage['medicineId']}, date: ${dosage['date']}, times: ${dosage['times']}, times: ${dosage['dosage']}');
              },
            ),
          ),
        )).toList(),
      ],
    );
  }
}
