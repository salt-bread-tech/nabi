import 'dart:async';
import 'dart:convert';
import 'package:doctor_nyang/screen/screen_diet_schedule.dart';
import 'package:doctor_nyang/screen/screen_schedule_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:doctor_nyang/widgets/widget_schedule.dart';
import 'package:intl/intl.dart';
import '../models/model_diet.dart';
import '../services/globals.dart';
import '../services/urls.dart';
import '../widgets/widget_diet.dart';
import '../widgets/widget_weekly_routine.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTab = 0;
  late DateTime selectedDate;
  List<dynamic> ingestionSchedule = [];

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    fetchIngestion();
  }

  FutureOr<Ingestion?> fetchIngestion() async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    final String url = '$baseUrl/ingestion/total/$userId/$formattedDate';

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
        Map<String, dynamic> ingestion = json.decode(responseBody);

        setState(() {
          ingestionSchedule = [ingestion];
        });
      } else {
        throw Exception('Failed to load ingestion');
      }
    } catch (e) {
      print('error: $e');
    }
  }

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
        fetchIngestion();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 10,
        backgroundColor: Colors.white,
        leading: Container(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 5),
                    child: Text(
                      '$nickName님 안녕하세요',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 15),
              ),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Text(
                  DateFormat('yyyy년 MM월 dd일').format(selectedDate),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ScheduleCalendar()));
                },
                child: WidgetSchedule(
                  datetime: selectedDate.toString(),
                  isWidget: true,
                ),
              ),
              SizedBox(height: 20),
              WidgetDiet(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => DietSchedule()));
                },
                isWidget: true,
                userCalories: bmr ?? 2000,
                breakfastCalories: ingestionSchedule.isNotEmpty
                    ? ingestionSchedule[0]['breakfastKcal']
                    : 0,
                lunchCalories: ingestionSchedule.isNotEmpty
                    ? ingestionSchedule[0]['lunchKcal']
                    : 0,
                dinnerCalories: ingestionSchedule.isNotEmpty
                    ? ingestionSchedule[0]['dinnerKcal']
                    : 0,
                snackCalories: ingestionSchedule.isNotEmpty
                    ? ingestionSchedule[0]['snackKcal']
                    : 0,
                totalProtein: ingestionSchedule.isNotEmpty
                    ? ingestionSchedule[0]['totalProtein']
                    : 0,
                totalCarb: ingestionSchedule.isNotEmpty
                    ? ingestionSchedule[0]['totalCarbohydrate']
                    : 0,
                totalFat: ingestionSchedule.isNotEmpty
                    ? ingestionSchedule[0]['totalFat']
                    : 0,
              ),
              SizedBox(height: 20),
              //RoutineStatusWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
