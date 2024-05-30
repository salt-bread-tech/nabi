import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../assets/theme.dart';
import '../models/model_diet.dart';
import '../services/globals.dart';
import '../services/urls.dart';
import 'package:http/http.dart' as http;

class WidgetDiet extends StatefulWidget {
  final DateTime date;

  WidgetDiet({
    required this.date,
  });

  @override
  _WidgetDietState createState() => _WidgetDietState();
}

class _WidgetDietState extends State<WidgetDiet> {
  List<dynamic> ingestionSchedule = [];

  @override
  void initState() {
    super.initState();
    fetchIngestion(widget.date);
  }

  Future<void> fetchIngestion(DateTime date) async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(date);
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

        ingestionSchedule = [ingestion];

        print('식단 조회 성공: ${ingestionSchedule}');
      } else {
        print('Failed to load ingestion: ${response.statusCode}');
        throw Exception('Failed to load ingestion');
      }
    } catch (e) {
      print('Error fetching ingestion: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final fontSize = screenSize.width * 0.032;
    double screenWidth = screenSize.width;
    double columnWidth = screenWidth * 0.1;

    return GestureDetector(
        child: Container(
            width: screenWidth - 50,
            height: screenSize.height * 0.19,
            decoration: BoxDecoration(
              color: AppTheme.widgetbackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: FutureBuilder(
                future: fetchIngestion(widget.date),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center();
                  } else if (snapshot.hasError) {
                    return Center(child: Text('식단 정보를 불러올 수 없습니다.'));
                  } else {
                    double totalCalories = ingestionSchedule[0]['breakfastKcal'] +
                        ingestionSchedule[0]['lunchKcal'] +
                        ingestionSchedule[0]['dinnerKcal'] +
                        ingestionSchedule[0]['snackKcal'];
                    String breakfastCaloriesToStr = ingestionSchedule.isNotEmpty
                        ? ingestionSchedule[0]['breakfastKcal'].toStringAsFixed(0)
                        : "0";
                    String lunchCaloriesToStr = ingestionSchedule.isNotEmpty
                        ? ingestionSchedule[0]['lunchKcal'].toStringAsFixed(0)
                        : "0";
                    String dinnerCaloriesToStr = ingestionSchedule.isNotEmpty
                        ? ingestionSchedule[0]['dinnerKcal'].toStringAsFixed(0)
                        : "0";
                    String snackCaloriesToStr = ingestionSchedule.isNotEmpty
                        ? ingestionSchedule[0]['snackKcal'].toStringAsFixed(0)
                        : "0";
                    String totalCaloriesToStr = totalCalories.toStringAsFixed(0);
                    String totalCarbToStr = ingestionSchedule.isNotEmpty
                        ? ingestionSchedule[0]['totalCarbohydrate'].toStringAsFixed(0)
                        : "0";
                    String totalProteinToStr = ingestionSchedule.isNotEmpty
                        ? ingestionSchedule[0]['totalProtein'].toStringAsFixed(0)
                        : "0";
                    String totalFatToStr = ingestionSchedule.isNotEmpty
                        ? ingestionSchedule[0]['totalFat'].toStringAsFixed(0)
                        : "0";

                    Color remainColor = totalCalories > 2000 ? Colors.red : Colors.white;
                    double remainCalories = bmr ?? 2000 - totalCalories;

                    List<PieChartSectionData> sections = [
                      if (ingestionSchedule.isNotEmpty) ...[
                        PieChartSectionData(
                            value: ingestionSchedule[0]['breakfastKcal'],
                            color: AppTheme.pastelPink,
                            title: '',
                            radius: 10),
                        PieChartSectionData(
                            value: ingestionSchedule[0]['lunchKcal'],
                            color: AppTheme.pastelBlue,
                            title: '',
                            radius: 10),
                        PieChartSectionData(
                            value: ingestionSchedule[0]['dinnerKcal'],
                            color: AppTheme.pastelGreen,
                            title: '',
                            radius: 10),
                        PieChartSectionData(
                            value: ingestionSchedule[0]['snackKcal'],
                            color: AppTheme.pastelYellow,
                            title: '',
                            radius: 10),
                        PieChartSectionData(
                            value: remainCalories, color: remainColor, title: '', radius: 10)
                      ],
                    ];

                    if (remainCalories < 0) {
                      remainColor = Color(0xFFFF5050);
                    } else {
                      remainColor = Colors.white;
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Spacer(flex: 8),
                                Text('아침',
                                    style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w600)),
                                Spacer(),
                                Text('점심',
                                    style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w600)),
                                Spacer(),
                                Text('저녁',
                                    style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w600)),
                                Spacer(),
                                Text('간식',
                                    style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w600)),
                                Spacer(flex: 8),
                              ],
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Spacer(flex: 8),
                                Text('$breakfastCaloriesToStr kcal',
                                    style: TextStyle(fontSize: fontSize)),
                                Spacer(),
                                Text('$lunchCaloriesToStr kcal',
                                    style: TextStyle(fontSize: fontSize)),
                                Spacer(),
                                Text('$dinnerCaloriesToStr kcal',
                                    style: TextStyle(fontSize: fontSize)),
                                Spacer(),
                                Text('$snackCaloriesToStr kcal',
                                    style: TextStyle(fontSize: fontSize)),
                                Spacer(flex: 8),
                              ],
                            )
                          ],
                        ),
                        Stack(alignment: Alignment.center, children: [
                          Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Spacer(),
                                Text(
                                  '총',
                                  style: TextStyle(fontSize: fontSize),
                                  textAlign: TextAlign.center,
                                ),
                                Text('$totalCaloriesToStr',
                                    style: TextStyle(
                                        fontSize: fontSize * 1.5,
                                        fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.center),
                                Text('kcal',
                                    style: TextStyle(fontSize: fontSize),
                                    textAlign: TextAlign.center),
                                Spacer(),
                              ]),
                          Container(
                              width: screenWidth * 0.01,
                              height: screenWidth * 0.01,
                              child: PieChart(
                                PieChartData(
                                  startDegreeOffset: -90,
                                  sections: sections,
                                  centerSpaceRadius: screenWidth * 0.1,
                                  sectionsSpace: totalCalories == 0 ? 0 : 3,
                                ),
                              ))
                        ]),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Spacer(flex: 8),
                                Text('탄수화물',
                                    style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w600)),
                                Spacer(),
                                Text('단백질',
                                    style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w600)),
                                Spacer(),
                                Text('지방',
                                    style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.w600)),
                                Spacer(flex: 8),
                              ],
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Spacer(flex: 8),
                                Text('$totalCarbToStr g',
                                    style: TextStyle(fontSize: fontSize)),
                                Spacer(),
                                Text('$totalProteinToStr g',
                                    style: TextStyle(fontSize: fontSize)),
                                Spacer(),
                                Text('$totalFatToStr g',
                                    style: TextStyle(fontSize: fontSize)),
                                Spacer(flex: 8),
                              ],
                            ),
                          ],
                        )
                      ],
                    );
                  }
                })));
  }
}
