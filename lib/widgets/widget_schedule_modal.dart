import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:doctor_nyang/assets/theme.dart';  // 가정한 경로
import '../services/globals.dart';
import '../services/urls.dart';

class AddScheduleModal extends StatefulWidget {
  final BuildContext parentContext;
  final DateTime initialDate;

  const AddScheduleModal({Key? key, required this.parentContext, required this.initialDate}) : super(key: key);

  @override
  _AddScheduleModalState createState() => _AddScheduleModalState();
}

class _AddScheduleModalState extends State<AddScheduleModal> {
  late DateTime selectedDate;
  String content = '';

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;  // 초기 선택된 날짜를 사용합니다.
  }

  Future<void> addSchedule() async {
    final String url = '$baseUrl/schedule';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'text': content,
          'date': DateFormat('yyyy-MM-ddTHH:mm:ss').format(selectedDate),
        }),
      );

      if (response.statusCode == 200) {
        print('Schedule added');
      } else {
        throw Exception('Failed to add schedule');
      }
    } catch (e) {
      print('error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(widget.parentContext).viewInsets.bottom),
        child: Container(
            width: double.infinity,
            height: 240,
            decoration: BoxDecoration(
              color: AppTheme.appbackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                    hintText: '새로운 일정',
                    labelStyle: TextStyle(color: Colors.black),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    content = value;
                  },
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('날짜', style: TextStyle(color: Colors.black)),
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
                                        initialDateTime: selectedDate,
                                        onDateTimeChanged: (DateTime newDateTime) {
                                          setState(() {
                                            selectedDate = newDateTime;
                                          });
                                        },
                                        use24hFormat: true,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: Text('확인'),
                                    ),
                                  ],
                                ),
                              );
                            }
                        );
                      },
                      child: Text(
                          '${selectedDate.year}년 ${selectedDate.month}월 ${selectedDate.day}일 ${selectedDate.hour}시 ${selectedDate.minute}분',
                          style: TextStyle(color: Colors.black)
                      ),
                    ),
                  ],
                ),
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
                          addSchedule();
                          Navigator.of(widget.parentContext).pop();  // 주의: context 대신 parentContext 사용
                          print('Schedule Added: $selectedDate $content');
                        },
                        child: Text('일정 추가', style: TextStyle(color: Colors.black))
                    )
                ),
              ],
            )
        )
    );
  }
}
