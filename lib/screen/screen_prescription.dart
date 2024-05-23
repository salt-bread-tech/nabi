import 'package:doctor_nyang/assets/theme.dart';
import 'package:doctor_nyang/services/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/urls.dart';
import '../widgets/widget_weeklyCalendar2.dart';
import '../widgets/widget_weekly_calendar.dart';

class Prescription {
  final String medicineName;
  final int dailyDosage;
  final int totalDosage;
  final int onceDosage;
  final String medicineDosage;

  Prescription({
    required this.medicineName,
    required this.dailyDosage,
    required this.totalDosage,
    required this.onceDosage,
    required this.medicineDosage,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      medicineName: json['medicineName'],
      dailyDosage: json['dailyDosage'],
      totalDosage: json['totalDosage'],
      onceDosage: json['onceDosage'],
      medicineDosage: json['medicineDosage'],
    );
  }
}

class PrescriptionScreen extends StatefulWidget {
  @override
  _PrescriptionScreenState createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  late DateTime selectedMonth;
  List<dynamic> prescriptions = [];
  List<Widget> widgets = [];
  List<Prescription> medicineTakings = [];
  Map<String, Prescription> prescription = {};
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime.now();
    getPrescriptionList();
  }

  Future<void> getPrescriptionList() async {
    final String url = '$baseUrl/prescriptions';

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
        List<dynamic> _prescriptions = json.decode(responseBody);
        setState(() {
          if (selectedMonth != null) {
            _prescriptions = _prescriptions.where((element) {
              DateTime date = DateTime.parse(element['date']);
              return date.year == selectedMonth.year &&
                  date.month == selectedMonth.month;
            }).toList();
          }
          prescriptions = _prescriptions;
        });
        print('처방전 목록 조회 성공');
      } else {
        print('처방전 목록 조회 실패');
      }
    } catch (e) {
      print('네트워크 오류 $e');
    }
  }

  Future<void> getPrescription(int id, int index) async {
    final String url = '$baseUrl/prescription/$id';

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
        Map<String, dynamic> _prescription = json.decode(responseBody);

        prescription = {};
        for (var item in _prescription['medicineTakings']) {
          prescription[item['medicineName']] = Prescription.fromJson(item);
        }

        showModalBottomSheet(
            context: context,
            scrollControlDisabledMaxHeightRatio: 0.8,
            builder: (BuildContext context) {
              return Container(
                width: double.infinity,
                height: 300 + prescriptions.length * 50.0,
                padding: EdgeInsets.symmetric(
                    horizontal: 30, vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          '${prescriptions[index]['name']}',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          '${prescriptions[index]['date']}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Column(
                      children: List<Widget>.generate(
                          prescription.length, (index) {
                        String medicineName = prescription
                            .keys
                            .elementAt(index);
                        Prescription medicine =
                        prescription[medicineName]!;
                        return Slidable(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                              BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                                  children: <Widget>[
                                    Text(
                                      '$medicineName',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '${medicine.totalDosage}일 ${medicine.dailyDosage}회 ${medicine.onceDosage}정(포) 복용',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${medicine.medicineDosage}',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              );
            });

        print('처방전 조회 성공');
      } else {
        print('처방전 조회 실패');
      }
    } catch (e) {
      print('네트워크 오류 $e');
    }
  }

  Future<void> addPrescription() async {
    final String url = '$baseUrl/prescriptions';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': '처방전 이름',
          'date': DateFormat('yyyy-MM-dd').format(_selectedDay),
          'medicineTakings': [
            {
              'medicineName': '약 이름',
              'dailyDosage': 1,
              'totalDosage': 1,
              'onceDosage': 1,
              'medicineDosage': '복용 방법',
            }
          ],
        }),
      );

      if (response.statusCode == 200) {
        print('처방전 추가 성공');
      } else {
        print('처방전 추가 실패');
      }
    } catch (e) {
      print('네트워크 오류 $e');
    }
  }

  void showPrescriptionAddModal() {
    showModalBottomSheet(
        scrollControlDisabledMaxHeightRatio: 0.8,
        enableDrag: true,
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
              child: Container(
            width: double.infinity,
            height: 300 + widgets.length * 90.0,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const SizedBox(
                        width: 130,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '처방전 이름',
                            hintStyle:
                                TextStyle(color: Colors.grey, fontSize: 16),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          showCupertinoModalPopup(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  height: 300,
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      Container(
                                        height: 200,
                                        child: CupertinoDatePicker(
                                          mode: CupertinoDatePickerMode.date,
                                          initialDateTime: _selectedDay,
                                          onDateTimeChanged:
                                              (DateTime newDateTime) {
                                            setState(() {
                                              _selectedDay = newDateTime;
                                            });
                                          },
                                          use24hFormat: true,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.pop(context);
                                          showPrescriptionAddModal();
                                        },
                                        child: Text('확인'),
                                      ),
                                    ],
                                  ),
                                );
                              });
                        },
                        child: Text(
                            '${DateFormat('yyyy년 MM월 dd일').format(_selectedDay)}',
                            style:
                                TextStyle(color: Colors.black, fontSize: 16)),
                      ),
                    ]),
                Column(
                  children: <Widget>[
                    Column(
                      children: widgets,
                    ),
                    SizedBox(height: 10),
                    Container(
                        width: double.infinity,
                        height: 55,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: BorderSide(color: Colors.black)),
                          ),
                          onPressed: () {
                            setState(() {
                              addWidget();
                              Navigator.pop(context);
                              showPrescriptionAddModal();
                            });
                          },
                          child: Text('약 추가',
                              style: TextStyle(color: Colors.black)),
                        )),
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
                          onPressed: () {
                            setState(() {
                              addWidget();
                              Navigator.pop(context);
                              showPrescriptionAddModal();
                            });
                          },
                          child: Text('처방전 등록',
                              style: TextStyle(color: Colors.black)),
                        )),
                  ],
                ),
              ],
            ),
          ));
        });
  }

  Column addMedicine() {
    return const Column(children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: 200,
            child: TextField(
              decoration: InputDecoration(
                hintText: '약 이름',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              style: TextStyle(color: Colors.black),
            ),
          ),
          SizedBox(
            width: 130,
            child: TextField(
              decoration: InputDecoration(
                hintText: '복용 방법',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
              ),
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            '총',
            style: TextStyle(color: Colors.black),
          ),
          SizedBox(
            width: 30,
            child: TextField(
              decoration: InputDecoration(
                hintStyle: TextStyle(color: Colors.grey),
                hintText: '1',
                border: InputBorder.none,
              ),
              style: TextStyle(color: Colors.black),
            ),
          ),
          Text(
            '일',
            style: TextStyle(color: Colors.black),
          ),
          Text(
            '하루',
            style: TextStyle(color: Colors.black),
          ),
          SizedBox(
            width: 30,
            child: TextField(
              decoration: InputDecoration(
                hintStyle: TextStyle(color: Colors.grey),
                hintText: '1',
                border: InputBorder.none,
              ),
              style: TextStyle(color: Colors.black),
            ),
          ),
          Text(
            '회',
            style: TextStyle(color: Colors.black),
          ),
          SizedBox(
            width: 30,
            child: TextField(
              decoration: InputDecoration(
                hintStyle: TextStyle(color: Colors.grey),
                hintText: '1',
                border: InputBorder.none,
              ),
              style: TextStyle(color: Colors.black),
            ),
          ),
          Text(
            '정(포)',
            style: TextStyle(color: Colors.black),
          ),
        ],
      )
    ]);
  }

  void addWidget() {
    widgets.add(addMedicine());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '$nickName님의 처방전',
          style: TextStyle(color: Colors.black, fontSize: 17),
          textAlign: TextAlign.center,
        ),
        iconTheme: IconThemeData(color: Colors.black),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              widgets = [];
              _selectedDay = DateTime.now();
              showPrescriptionAddModal();
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.keyboard_arrow_left),
                    onPressed: () {
                      setState(() {
                        selectedMonth = DateTime(
                            selectedMonth.year, selectedMonth.month - 1);
                        getPrescriptionList();
                      });
                    },
                  ),
                  Text(
                    '${DateFormat('yyyy년 MM월').format(selectedMonth)}',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.keyboard_arrow_right),
                    onPressed: () {
                      setState(() {
                        selectedMonth = DateTime(
                            selectedMonth.year, selectedMonth.month + 1);
                        getPrescriptionList();
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
                child: ListView.builder(
                    itemCount: prescriptions.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                          onTap: () {
                            getPrescription(
                                prescriptions[index]['prescriptionId'], index);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppTheme.pastelYellow,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      '${prescriptions[index]['name']}',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '${prescriptions[index]['date']}',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ));
                    }))
          ],
        ),
      ),
    );
  }
}
