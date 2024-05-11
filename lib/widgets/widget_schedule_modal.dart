import 'dart:convert';

import 'package:doctor_nyang/assets/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:date_time_picker/date_time_picker.dart';

import '../services/globals.dart';
import '../services/urls.dart';

void showAddScheduleModal(BuildContext context) {
  DateTime selectedDate = DateTime.now();
  String content = '';

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

  showModalBottomSheet(
    context: context,
    builder: (bCtx) {
      return Container(
        width: double.infinity,
        height: 300,
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
              DateTimePicker(
                type: DateTimePickerType.dateTimeSeparate,
                dateMask: 'yyyy/MM/dd',
                initialValue: DateFormat('yyyy/MM/dd').format(selectedDate),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                icon: Icon(Iconsax.calendar),
                onChanged: (val) {
                  selectedDate = DateTime.parse(val);
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: '일정'),
                onChanged: (value) {
                  content = value;
                },
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[],
              ),
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
                        Navigator.of(context).pop();
                        print('Schedule Added: $selectedDate $content');
                      },
                      child: Text('일정 추가', style: TextStyle(color: Colors.black)))),
            ],
          ));
    },
  );
}
