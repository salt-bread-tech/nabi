import 'dart:async';

import 'package:doctor_nyang/services/globals.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/model_diet.dart';
import '../services/urls.dart';
import '../widgets/widget_diet.dart';

class DietSchedule extends StatefulWidget {
  @override
  _DietScheduleState createState() => _DietScheduleState();
}

class _DietScheduleState extends State<DietSchedule> {
  late DateTime selectedDate;
  List<dynamic> dietSchedule = [];
  List<dynamic> ingestionSchedule = [];

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    fetchIngestion();
    fetchDietSchedule();
  }

  Future<void> fetchDietSchedule() async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    final String url = '$baseUrl/diet/$userId/$formattedDate';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        String responseBody = utf8.decode(response.bodyBytes);
        List<dynamic> diet = json.decode(responseBody);

        setState(() {
          dietSchedule = diet;
        });
        print(dietSchedule);
      } else {
        print('복용 일정 조회 실패');
      }
    } catch (e) {
      print('네트워크 오류 $e');
    }
  }

  FutureOr<Ingestion?> fetchIngestion() async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    final String url = '$baseUrl/ingestion/total/$userId/$formattedDate';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
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
        fetchDietSchedule();
      });
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
          '$nickName님의 식단 관리',
          style: TextStyle(color: Colors.black, fontSize: 17),
          textAlign: TextAlign.center,
        ),
        iconTheme: IconThemeData(color: Colors.black),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/FoodSearch');
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Text(
                DateFormat('yyyy년 MM월 dd일').format(selectedDate),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            SizedBox(height: 20),
            WidgetDiet(
              onTap: () {},
              isWidget: false,
              userCalories: 2000,
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
            Expanded(
              child: ListView.builder(
                itemCount: dietSchedule.length,
                itemBuilder: (context, index) {
                  var diet = dietSchedule[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Row(children: [
                        Text(diet['name'],
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                        SizedBox(width: 5),
                        Text('${diet['servingSize'].toStringAsFixed(0)}g',
                            style: TextStyle(fontSize: 10)),
                      ]),
                      subtitle:
                      Text(
                          '탄수화물 ${diet['carbohydrate'] >= 9999999.0 ? "-g" : "${diet['carbohydrate'].toStringAsFixed(0)}g"} 단백질 ${diet['protein'] >= 9999999.0 ? "-g" : "${diet['protein'].toStringAsFixed(0)}g"} 지방 ${diet['fat'] >= 9999999.0 ? "-g" : "${diet['fat'].toStringAsFixed(0)}g"}',
                          style: TextStyle(fontSize: 11)),
                      trailing: Text(
                          '${diet['calories'].toStringAsFixed(0)}kcal',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
