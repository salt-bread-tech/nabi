import 'dart:async';
import 'dart:convert';
import 'package:doctor_nyang/screen/screen_diet_schedule.dart';
import 'package:doctor_nyang/screen/screen_dosage_schedule.dart';
import 'package:doctor_nyang/screen/screen_prescription.dart';
import 'package:doctor_nyang/screen/screen_routine.dart';
import 'package:doctor_nyang/screen/screen_schedule_calendar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:doctor_nyang/widgets/widget_schedule.dart';
import 'package:intl/intl.dart';
import '../models/model_diet.dart';
import '../services/globals.dart';
import '../services/globals.dart' as globals;
import '../services/service_auth.dart';
import '../services/service_home_widget.dart';
import '../services/urls.dart';
import '../widgets/widget_calendar.dart';
import '../widgets/widget_diet.dart';
import '../widgets/widget_dosageSchedule.dart';
import '../widgets/widget_routineList.dart';
import '../widgets/widget_weekly_calendar.dart';
import '../widgets/widget_prescription.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTab = 0;
  late DateTime selectedDate;
  List<dynamic> ingestionSchedule = [];
  String _selectedDateRange = '';

  void _handleDateChange(DateTime newDate) {
    setState(() {
      selectedDate = newDate.toUtc();
      fetchIngestion();
    });
  }

  void refreshData() {
    setState(() {
      selectedDate = selectedDate.toUtc();
      _selectedDateRange = _formatDateRange(selectedDate.toUtc());
      fetchIngestion();
    });
  }

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now().toUtc();
    _selectedDateRange = _formatDateRange(selectedDate.toUtc());
    fetchIngestion();
    fetchUserInfo();
  }

  FutureOr<Ingestion?> fetchIngestion() async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.toUtc());
    final String url = '$baseUrl/ingestion/total/$formattedDate';

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

  String _formatDateRange(DateTime date) {
    int weekday = date.toUtc().weekday;
    DateTime startOfWeek = date.toUtc().subtract(Duration(days: weekday - 1));
    DateTime endOfWeek = startOfWeek.toUtc().add(Duration(days: 6));
    return '${DateFormat('M.dd').format(startOfWeek.toUtc())}~${DateFormat('M.dd').format(endOfWeek.toUtc())}';
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final fontSize = screenSize.width * 0.036; // 화면 너비에 비례하여 폰트 크기 설정
    getWidgetOrder();
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
            children: <Widget>[

              SizedBox(height: 20),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 15),
              ),
              WidgetCalendar(onDateSelected: _handleDateChange),
              SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ScheduleCalendar()),
                  );
                  refreshData();
                },
                child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              padding: EdgeInsets.only(left: 5),
                              margin: EdgeInsets.only(bottom: 10),
                              child: Text('일정')),
                          WidgetSchedule(
                            datetime: selectedDate.toUtc().toString(),
                            isWidget: true,
                          )
                        ])),
              ),
              SizedBox(height: 20),
              Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                            padding: EdgeInsets.only(left: 5),
                            margin: EdgeInsets.only(bottom: 10),
                            child: Text('식단')),
                        WidgetDiet(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => DietSchedule()),
                            );
                            refreshData();
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
                        )
                      ])),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RoutineScreen(),
                    ),
                  );
                  refreshData();
                },
                child: Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            alignment: Alignment.topCenter,
                            child: RoutineListWidget(
                              key: ValueKey(DateFormat('yyyy-MM-dd')
                                  .format(selectedDate.toUtc())),
                              datetime:
                              DateFormat('yyyy-MM-dd').format(selectedDate.toUtc()),
                            ),
                          )
                        ])),
              ),
              SizedBox(height: 20),
              GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrescriptionScreen(),
                      ),
                    );
                    refreshData();
                  },
                  child: Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                padding: EdgeInsets.only(left: 5),
                                margin: EdgeInsets.only(bottom: 10),
                                child: Text('처방전')),
                            WidgetPrescription(
                                datetime: DateFormat('yyyy-MM-dd')
                                    .format(selectedDate.toUtc()))
                          ]))),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DosageSchedule(),
                    ),
                  );
                  refreshData();
                },
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          padding: EdgeInsets.only(left: 5),
                          margin: EdgeInsets.only(bottom: 10),
                          child: Text('의약품 복용 일정')),
                      WidgetDosage(
                          datetime: DateFormat('yyyy-MM-dd')
                              .format(selectedDate.toUtc()))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
