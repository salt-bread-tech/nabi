import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../assets/theme.dart';

class WidgetDiet extends StatefulWidget {
  final double breakfastCalories;
  final double lunchCalories;
  final double dinnerCalories;
  final double snackCalories;
  final double userCalories;

  final double totalCarb;
  final double totalProtein;
  final double totalFat;

  final VoidCallback onTap;
  final bool isWidget;

  WidgetDiet({
    required this.breakfastCalories,
    required this.lunchCalories,
    required this.dinnerCalories,
    required this.snackCalories,
    required this.userCalories,
    required this.totalCarb,
    required this.totalProtein,
    required this.totalFat,
    required this.onTap,
    required this.isWidget,
  });

  @override
  _WidgetDietState createState() => _WidgetDietState();
}

class _WidgetDietState extends State<WidgetDiet> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final fontSize = 12.0;
    double screenWidth = screenSize.width;
    double columnWidth = screenWidth * 0.1;

    Color remainColor = Colors.white;
    double totalCalories = widget.breakfastCalories +
        widget.lunchCalories +
        widget.dinnerCalories +
        widget.snackCalories;
    double remainCalories = widget.userCalories - totalCalories;

    String breakfastCaloriesToStr = widget.breakfastCalories.toStringAsFixed(0);
    String lunchCaloriesToStr = widget.lunchCalories.toStringAsFixed(0);
    String dinnerCaloriesToStr = widget.dinnerCalories.toStringAsFixed(0);
    String snackCaloriesToStr = widget.snackCalories.toStringAsFixed(0);
    String totalCaloriesToStr = totalCalories.toStringAsFixed(0);
    String totalCarbToStr = widget.totalCarb.toStringAsFixed(0);
    String totalProteinToStr = widget.totalProtein.toStringAsFixed(0);
    String totalFatToStr = widget.totalFat.toStringAsFixed(0);

    if (remainCalories < 0) {
      remainColor = Color(0xFFFF5050);
    }

    List<PieChartSectionData> sections = [
      PieChartSectionData(
          value: widget.breakfastCalories,
          color: AppTheme.pastelPink,
          title: '',
          radius: 10),
      PieChartSectionData(
          value: widget.lunchCalories,
          color: AppTheme.pastelBlue,
          title: '',
          radius: 10),
      PieChartSectionData(
          value: widget.dinnerCalories,
          color: AppTheme.pastelGreen,
          title: '',
          radius: 10),
      PieChartSectionData(
          value: widget.snackCalories,
          color: AppTheme.pastelYellow,
          title: '',
          radius: 10),
      PieChartSectionData(
          value: remainCalories, color: remainColor, title: '', radius: 10)
    ];

    return GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: screenWidth - 50,
          height: screenSize.height * 0.19,
          decoration: BoxDecoration(
            color: AppTheme.widgetbackgroundColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.isWidget
                    ? Colors.transparent
                    : Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
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
                              fontSize: fontSize, fontWeight: FontWeight.w600)),
                      Spacer(),
                      Text('점심',
                          style: TextStyle(
                              fontSize: fontSize, fontWeight: FontWeight.w600)),
                      Spacer(),
                      Text('저녁',
                          style: TextStyle(
                              fontSize: fontSize, fontWeight: FontWeight.w600)),
                      Spacer(),
                      Text('간식',
                          style: TextStyle(
                              fontSize: fontSize, fontWeight: FontWeight.w600)),
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
                          style: TextStyle(fontSize: fontSize) ),
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
                              fontSize: fontSize, fontWeight: FontWeight.w600)),
                      Spacer(),
                      Text('단백질',
                          style: TextStyle(
                              fontSize: fontSize, fontWeight: FontWeight.w600)),
                      Spacer(),
                      Text('지방',
                          style: TextStyle(
                              fontSize: fontSize, fontWeight: FontWeight.w600)),
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
          ),
        ));
  }
}
