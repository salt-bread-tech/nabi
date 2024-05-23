import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../services/globals.dart';
import '../services/urls.dart';

class PrescriptionAddModal extends StatefulWidget {
  final DateTime initialDate;
  final Function(List<Widget>) onAdd;


  PrescriptionAddModal({required this.initialDate, required this.onAdd});

  @override
  _PrescriptionAddModalState createState() => _PrescriptionAddModalState();
}

class _PrescriptionAddModalState extends State<PrescriptionAddModal> {
  DateTime _selectedDay;
  List<Widget> widgets = [];

  _PrescriptionAddModalState() : _selectedDay = DateTime.now();

  final TextEditingController _prescriptionNameController = TextEditingController();

  Future<void> addPrescription({required String name, required String date}) async {
    final String url = '$baseUrl/prescriptions';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'name': name, 'date': date}),
      );

      if (response.statusCode == 200) {
        print('처방전 등록 성공');
      } else {
        print('처방전 등록 실패');
        print('name: $name, date: $date');
      }
    } catch (e) {
      print('네트워크 오류 $e');
    }
  }

  void _registerPrescription() async {
    try {
      await addPrescription(
        name: _prescriptionNameController.text,
        date: DateFormat('yyyy-MM-dd').format(_selectedDay),
      );
      widget.onAdd(widgets);
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("처방전 등록 실패: $e")),
      );
    }
  }


  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDate;
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
    setState(() {
      widgets.add(addMedicine());
    });
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        width: double.infinity,
        height: 180 + widgets.length * 80.0,
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  SizedBox(
                    width: 130,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '처방전 이름',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                        border: InputBorder.none,
                      ),
                      controller: _prescriptionNameController,
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
                                      onDateTimeChanged: (DateTime newDateTime) {
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
                        style: TextStyle(color: Colors.black, fontSize: 16)),
                  ),
                ]),
            Column(
              children: <Widget>[
                Column(
                  children: widgets,
                ),
                Container(
                  width: double.infinity,
                  height: 55,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _registerPrescription,
                    child: Text('완료', style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}