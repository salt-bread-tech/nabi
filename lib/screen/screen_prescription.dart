import 'package:doctor_nyang/assets/theme.dart';
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

class Prescription{
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
  Map<String, Prescription> prescription = {};

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

  Future<void> getPrescription(int id) async {
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
        print(_prescription);

        for (var item in _prescription['medicineTakings']) {
          prescription[item['medicineName']] = Prescription.fromJson(item);
          print(prescription[item['medicineName']]?.medicineName);
        }

        print (prescription['보령아스트릭스캡슐100밀리그람']?.medicineName);



        print('처방전 조회 성공');
      } else {
        print('처방전 조회 실패');
      }
    } catch (e) {
      print('네트워크 오류 $e');
    }
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
            onPressed: () {},
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
                                prescriptions[index]['prescriptionId']);
                            showModalBottomSheet(context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                    width: double.infinity,
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
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment
                                              .spaceBetween,
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
                                            String medicineName = prescription.keys
                                                .elementAt(index);
                                            Prescription medicine = prescription[
                                            medicineName]!;
                                            return Slidable(
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 20, vertical: 10),
                                                decoration: BoxDecoration(
                                                  color: AppTheme.pastelYellow,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .spaceBetween,
                                                  children: <Widget>[
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment
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