import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../assets/theme.dart';

class WidgetDiet extends StatelessWidget {
  final double breakfastCalories;
  final double lunchCalories;
  final double dinnerCalories;
  final double snackCalories;
  final double userCalories;

  final double totalCarb;
  final double totalProtein;
  final double totalFat;

  WidgetDiet({
    required this.breakfastCalories,
    required this.lunchCalories,
    required this.dinnerCalories,
    required this.snackCalories,
    required this.userCalories,
    required this.totalCarb,
    required this.totalProtein,
    required this.totalFat,
  });

  @override
  Widget build(BuildContext context) {
    Color remainColor = Colors.white;
    double totalCalories =
        breakfastCalories + lunchCalories + dinnerCalories + snackCalories;
    double remainCalories = userCalories - totalCalories;

    String breakfastCaloriesToStr = breakfastCalories.toStringAsFixed(0);
    String lunchCaloriesToStr = lunchCalories.toStringAsFixed(0);
    String dinnerCaloriesToStr = dinnerCalories.toStringAsFixed(0);
    String snackCaloriesToStr = snackCalories.toStringAsFixed(0);
    String totalCaloriesToStr = totalCalories.toStringAsFixed(0);
    String totalCarbToStr = totalCarb.toStringAsFixed(0);
    String totalProteinToStr = totalProtein.toStringAsFixed(0);
    String totalFatToStr = totalFat.toStringAsFixed(0);

    if (remainCalories < 0) {
      remainColor = Colors.red;
    }

    List<PieChartSectionData> sections = [
      PieChartSectionData(
          value: breakfastCalories,
          color: AppTheme.pastelPink,
          title: '',
          radius: 10),
      PieChartSectionData(
          value: lunchCalories,
          color: AppTheme.pastelBlue,
          title: '',
          radius: 10),
      PieChartSectionData(
          value: dinnerCalories,
          color: AppTheme.pastelGreen,
          title: '',
          radius: 10),
      PieChartSectionData(
          value: snackCalories,
          color: AppTheme.pastelYellow,
          title: '',
          radius: 10),
      PieChartSectionData(
          value: remainCalories, color: remainColor, title: '', radius: 10)
    ];

    return Stack(
      children: [
        Align(
          child: Container(
            width: 330,
            height: 150,
            decoration: BoxDecoration(
              color: AppTheme.widgetbackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(),
                        1: FixedColumnWidth(65),
                      },
                      children: [
                        TableRow(children: [
                          Text('아침',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                          Text(' $breakfastCaloriesToStr kcal',
                              style: TextStyle(fontSize: 11)),
                        ]),
                        TableRow(children: [SizedBox(height: 5), SizedBox()]),
                        TableRow(children: [
                          Text('점심',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                          Text(' $lunchCaloriesToStr kcal',
                              style: TextStyle(fontSize: 11)),
                        ]),
                        TableRow(children: [SizedBox(height: 5), SizedBox()]),
                        TableRow(children: [
                          Text('저녁',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                          Text(' $dinnerCaloriesToStr kcal',
                              style: TextStyle(fontSize: 11)),
                        ]),
                        TableRow(children: [SizedBox(height: 5), SizedBox()]),
                        TableRow(children: [
                          Text('간식',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                          Text(' $snackCaloriesToStr kcal',
                              style: TextStyle(fontSize: 11)),
                        ]),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: PieChart(
                    PieChartData(
                      startDegreeOffset: -90,
                      sections: sections,
                      centerSpaceRadius: 40,
                      sectionsSpace: 3,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(),
                        1: FixedColumnWidth(50),
                      },
                      children: [
                        TableRow(children: [
                          Text('탄수화물',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                          Text(' $totalCarbToStr g',
                              style: TextStyle(fontSize: 11)),
                        ]),
                        TableRow(children: [SizedBox(height: 10), SizedBox()]),
                        TableRow(children: [
                          Text('단백질',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                          Text(' $totalProteinToStr g',
                              style: TextStyle(fontSize: 11)),
                        ]),
                        TableRow(children: [SizedBox(height: 10), SizedBox()]),
                        TableRow(children: [
                          Text('지방',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                          Text(' $totalFatToStr g',
                              style: TextStyle(fontSize: 11)),
                        ]),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
            top: 48,
          left: 148,
          width: 60,

            child: Table(children: [
              TableRow(children: [
                Text('총', style: TextStyle(fontSize: 12), textAlign: TextAlign.center,),
              ]),
              TableRow(children: [
                Text('$totalCaloriesToStr',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
              ]),
              TableRow(children: [
                Text('kcal', style: TextStyle(fontSize: 12), textAlign: TextAlign.center),
              ])
            ]))
      ],
    );
  }
}