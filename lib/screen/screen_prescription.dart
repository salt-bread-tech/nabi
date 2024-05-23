import 'package:doctor_nyang/assets/theme.dart';
import 'package:doctor_nyang/screen/screen_prescription_info.dart';
import 'package:doctor_nyang/services/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/urls.dart';
import '../widgets/widget_addPrescription.dart';


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
  Map<String, Prescription> prescription = {};
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime.now();
    getPrescriptionList();
  }

  void refreshRoutines() {
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

        prescription = {};
        for (var item in _prescription['medicineTakings']) {
          prescription[item['medicineName']] = Prescription.fromJson(item);
        }

        print('처방전 조회 성공');
      } else {
        print('처방전 조회 실패');
      }
    } catch (e) {
      print('네트워크 오류 $e');
    }
  }

  void showPrescriptionAddModal() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return PrescriptionAddModal(
            initialDate: _selectedDay,
            onAdd: (List<Widget> addedWidgets) {
              setState(() {
                widgets = addedWidgets;
                getPrescriptionList(); // 처방전 목록 새로고침
              });
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '나만의 처방전',
          style: TextStyle(color: Colors.black, fontSize: 17),
          textAlign: TextAlign.center,
        ),
        iconTheme: IconThemeData(color: Colors.black),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              widgets = [];
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
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PrescriptionInfoScreen(id: prescriptions[index]['prescriptionId']),
                              ),
                            );
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
                          ),
                        ),
                      );
                    }))
          ],
        ),
      ),
    );
  }
}
