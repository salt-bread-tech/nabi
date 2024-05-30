import 'dart:collection';

import 'package:doctor_nyang/assets/theme.dart';
import 'package:doctor_nyang/screen/screen_medicine_info.dart';
import 'package:doctor_nyang/screen/screen_medicine_search.dart';
import 'package:doctor_nyang/services/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/urls.dart';
import '../widgets/widget_addPrescription.dart';
import '../widgets/widget_calendar.dart';

class Prescription {
  final String prescriptionName;
  final String prescriptionDate;
  final List<MedicineTaking> medicineTakings;

  Prescription({
    required this.prescriptionName,
    required this.prescriptionDate,
    required this.medicineTakings,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    var list = json['medicineTakings'] as List;
    List<MedicineTaking> medicineTakingsList =
    list.map((i) => MedicineTaking.fromJson(i)).toList();

    return Prescription(
      prescriptionName: json['prescriptionName'],
      prescriptionDate: json['prescriptionDate'],
      medicineTakings: medicineTakingsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prescriptionName': prescriptionName,
      'prescriptionDate': prescriptionDate,
      'medicineTakings': medicineTakings.map((e) => e.toJson()).toList(),
    };
  }
}

class MedicineTaking {
  final int medicineId;
  final String medicineName;
  final int once;
  final int days;
  final List<int> time;
  final String dosage;
  final bool registeredDosingSchedule;

  MedicineTaking({
    required this.medicineId,
    required this.medicineName,
    required this.once,
    required this.days,
    required this.time,
    required this.dosage,
    required this.registeredDosingSchedule,
  });

  factory MedicineTaking.fromJson(Map<String, dynamic> json) {
    return MedicineTaking(
      medicineId: json['medicineId'],
      medicineName: json['medicineName'],
      once: json['once'],
      days: json['days'],
      time: List<int>.from(json['time']),
      dosage: json['dosage'],
      registeredDosingSchedule: json['registeredDosingSchedule'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicineId': medicineId,
      'medicineName': medicineName,
      'once': once,
      'days': days,
      'time': time,
      'dosage': dosage,
      'registeredDosingSchedule': registeredDosingSchedule,
    };
  }
}

class PrescriptionInfoforDosage extends StatefulWidget {
  final int id;
  final String? fromRoute;

  PrescriptionInfoforDosage({
    required this.id,
    this.fromRoute,
  });

  @override
  _PrescriptionInfoScreenState createState() => _PrescriptionInfoScreenState();
}

class _PrescriptionInfoScreenState extends State<PrescriptionInfoforDosage> {
  late DateTime selectedMonth;
  Map<String, dynamic> prescription = {};
  List<dynamic> medicineTakings = [];
  Map<String, dynamic> medicineTaking = {};
  List<String> time = ['아침', '점심', '저녁', '취침 전'];
  List<String> medicineTakingTimes = ['식전', '식중', '식후', '상관 없음'];
  List<String> selectedTime = [];
  int selectedMedicineTakingTimes = 0;
  List<Color> registeredDosingScheduleColor = [
    AppTheme.pastelPink.withOpacity(0.5),
    AppTheme.pastelBlue.withOpacity(0.5),
  ];
  List<String> registeredDosingScheduleText = ['일정 추가 하기', '일정 추가 완료'];
  String medicineName = '';
  TextEditingController medicineNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime.now();
    getPrescription(widget.id);
  }

  @override
  void dispose() {
    medicineNameController.dispose();
    super.dispose();
  }

  Future<void> getPrescription(int id) async {
    final String url = '$baseUrl/prescriptions/$id';

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

        final Map<String, dynamic> _data = jsonDecode(responseBody);
        final _prescription = Prescription.fromJson(_data);
        final _medicineTakings = _data['medicineTakings'] as List;
        _medicineTakings.forEach((element) {
          medicineTakings.add(MedicineTaking.fromJson(element));
        });

        setState(() {
          prescription = _prescription.toJson();
          medicineTakings = _medicineTakings;
        });

        medicineTakings.forEach((element) {
          setState(() {
            medicineTaking = element;
            selectedTime = time
                .where((element) =>
                medicineTaking['time'].contains(time.indexOf(element)))
                .toList();
          });
        });

        print('처방전 조회 성공');
      } else {
        print('처방전 조회 실패');
      }
    } catch (e) {
      print('네트워크 오류 $e');
    }
  }

  Future<void> addDosage(
      {required int medicineId, required String date, required int time, required int dosage}) async {
    final String url = '$baseUrl/dosage/custom';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'medicineId': medicineId,
          'date': date,
          'time': time,
          'dosage': dosage,
        }),
      );

      if (response.statusCode == 200) {
        print('복용 일정 추가 성공');
      } else {
        print('복용 일정 추가 실패');
      }
    } catch (e) {
      print('네트워크 오류 $e');
    }
  }

  void showAddDosageModal(BuildContext context, int medicineId) {
    DateTime selectedDate = DateTime.now();
    int selectedTime = 0;
    int selectedDosage = 0;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: 400,
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('복용 일정 추가하기', style: TextStyle(fontSize: 17,fontWeight: FontWeight.w600)),
                      Spacer(),
                      IconButton(
                        onPressed: () {
                          _showDatePickerPopup(context, (selectedDay) {
                            setState(() {
                              selectedDate = selectedDay;
                            });
                          });
                        },
                        icon: Icon(Iconsax.calendar_2, size: 20),
                      ),
                      Text('${DateFormat('yyyy-MM-dd').format(selectedDate)}', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text('의약품명 : ${medicineTaking['medicineName']}', style: TextStyle(fontSize: 15)),
                  SizedBox(height: 20),
                  Text('복용 시간'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: time
                        .map((e) => ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedTime = time.indexOf(e);
                        });
                      },
                      child: Text(e, style: TextStyle(color: Colors.black,fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: selectedTime == time.indexOf(e) ? AppTheme.pastelBlue : Colors.grey[200],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ))
                        .toList(),
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
                  SizedBox(height: 10),
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
                      onPressed: () async{
                        print('$medicineId, ${DateFormat('yyyy-MM-dd').format(selectedDate)}, $selectedTime $selectedDosage');
                        await addDosage(
                          medicineId: medicineId,
                          date: DateFormat('yyyy-MM-dd').format(selectedDate.toUtc()),
                          time: selectedTime,
                          dosage: selectedDosage,
                        );
                        Navigator.pop(context);
                      },
                      child: Text('등록하기', style: TextStyle(color: Colors.black)),
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

  void _showDatePickerPopup(BuildContext context, Function(DateTime) onDateSelected) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 400,
          color: Colors.white,
          child: Column(
            children: [
              WidgetCalendarMonth(
                onDateSelected: (selectedDay) {
                  onDateSelected(selectedDay);
                  Navigator.pop(context);
                },
              ),
            ],
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
        elevation: 0,
        title: Text(
          '${prescription['prescriptionName']}',
          style: TextStyle(color: Colors.black, fontSize: 17),
          textAlign: TextAlign.center,
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: prescription['medicineTakings'] == null ||
              prescription['medicineTakings'].isEmpty
              ? Center(
              child: Text('처방전 내용이 없습니다.',
                  textAlign: TextAlign.center))
              : ListView(
            children: [
              Container(
                padding:
                EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Spacer(),
                      Text(
                        '${prescription['prescriptionDate']}',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ]),
              ),
              Column(
                children: List.generate(
                    prescription['medicineTakings'].length, (index) {
                  var medicineTaking =
                  prescription['medicineTakings'][index];
                  return Container(
                      margin: EdgeInsets.only(bottom: 20),
                        child: GestureDetector(
                          onTap: () {
                            showAddDosageModal(context, medicineTaking['medicineId']);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        bottomLeft: Radius.circular(30),
                                      ),
                                      color: Color(0xFFE8F3FF),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${medicineTaking['medicineName']}',
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          '${medicineTaking['time'].map((e) => time[e]).toList().join(' ')}',
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                            '${medicineTaking['days']}일 동안 하루에 ${medicineTaking['time'].length}번 ${medicineTaking['once']}정(포) ',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            )),
                                      ],
                                    )),
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 20,horizontal: 20),decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(30),
                                    bottomRight: Radius.circular(30),),
                                  color: Colors.white,
                                ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('',style: TextStyle(fontSize: 13),),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                }),
              ),
            ],
          )),
    );
  }
}