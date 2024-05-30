import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../services/globals.dart';
import '../services/urls.dart';

class PrescriptionEditModal extends StatefulWidget {
  final DateTime initialDate;
  final int id;
  final String name;
  final Function(List<Widget>) onAdd;

  PrescriptionEditModal(
      {required this.initialDate,
      required this.id,
      required this.name,
      required this.onAdd});

  @override
  _PrescriptionEditModalState createState() => _PrescriptionEditModalState();
}

class _PrescriptionEditModalState extends State<PrescriptionEditModal> {
  DateTime _selectedDay;
  List<Widget> widgets = [];

  _PrescriptionEditModalState() : _selectedDay = DateTime.now();

  final TextEditingController _prescriptionNameController =
      TextEditingController();

  void _editPrescription() async {
    try {
      await editPrescription(
        id: widget.id,
        name: _prescriptionNameController.text,
        date: DateFormat('yyyy-MM-dd').format(_selectedDay),
      );
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("처방전 수정 실패: $e")),
      );
    }
  }

  Future<void> editPrescription(
      {required int id, required String name, required String date}) async {
    final String url = '$baseUrl/prescription';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(
          {'prescriptionId': id, 'name': name, 'date': date},
        ),
      );

      if (response.statusCode == 200) {
        print('처방전 수정 성공');
      } else {
        print('처방전 수정 실패');
      }
    } catch (e) {
      print('네트워크 오류 $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDate;
    _prescriptionNameController.text = widget.name;
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize16 = screenWidth * 0.04;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        width: double.infinity,
        height: 170,
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
                    width: screenWidth * 0.5,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '처방전 이름',
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: fontSize16),
                        border: InputBorder.none,
                      ),
                      controller: _prescriptionNameController,
                      style:
                          TextStyle(color: Colors.black, fontSize: fontSize16),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      showCupertinoModalPopup(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                              height: 260,
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
                                      Navigator.pop(context);
                                    },
                                    child: Text('확인',
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                ],
                              ),
                            );
                          });
                    },
                    child: Text(
                        '${DateFormat('yyyy년 MM월 dd일').format(_selectedDay)}',
                        style: TextStyle(
                            color: Colors.black, fontSize: fontSize16)),
                  ),
                ]),
            Column(
              children: <Widget>[
                Column(
                  children: widgets,
                ),
                SizedBox(height: 15),
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
                    onPressed: _editPrescription,
                    child: Text(
                      '수정',
                      style: TextStyle(color: Colors.black),
                    ),
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
