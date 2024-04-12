import 'dart:async';

import 'package:doctor_nyang/services/globals.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/urls.dart';
import '../services/service_diet.dart';
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
              Navigator.pushNamed(context, '/MedicineSearch');
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
            Expanded(
              child: ListView.builder(
                itemCount: dietSchedule.length,
                itemBuilder: (context, index) {
                  var dosage = dietSchedule[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      title: Text('${dosage['medicineName']}'),
                      subtitle:
                          Text('복용 시간: ${dosage['times']},${dosage['date']}'),
                      trailing: Icon(
                        dosage['medicineTaken']
                            ? Icons.check_circle
                            : Icons.check_circle_outline,
                        color: dosage['medicineTaken']
                            ? Colors.green
                            : Colors.grey,
                      ),
                      onTap: () {
                        print(
                            'userId: $userId, medicineId: ${dosage['medicineId']}, date: ${dosage['date']}, times: ${dosage['times']}');
                      },
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
