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

    Color remainColor = Colors.white;
    double totalCalories =
        widget.breakfastCalories + widget.lunchCalories + widget.dinnerCalories + widget.snackCalories;
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
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              child: Container(
                width: MediaQuery.of(context).size.width - 50,
                height: 150,
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
                  children: [
                    SizedBox(width: 20),
                    Expanded(
                      flex: 1,
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(),
                          1: FixedColumnWidth(70),
                        },
                        children: [
                          TableRow(children: [
                            Text('아침',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600)),
                            Text('$breakfastCaloriesToStr kcal',
                                style: TextStyle(fontSize: 11)),
                          ]),
                          TableRow(children: [SizedBox(height: 5), SizedBox()]),
                          TableRow(children: [
                            Text('점심',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600)),
                            Text('$lunchCaloriesToStr kcal',
                                style: TextStyle(fontSize: 11)),
                          ]),
                          TableRow(children: [SizedBox(height: 5), SizedBox()]),
                          TableRow(children: [
                            Text('저녁',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600)),
                            Text('$dinnerCaloriesToStr kcal',
                                style: TextStyle(fontSize: 11)),
                          ]),
                          TableRow(children: [SizedBox(height: 5), SizedBox()]),
                          TableRow(children: [
                            Text('간식',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600)),
                            Text('$snackCaloriesToStr kcal',
                                style: TextStyle(fontSize: 11)),
                          ]),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: PieChart(
                        PieChartData(
                          startDegreeOffset: -90,
                          sections: sections,
                          centerSpaceRadius: 40,
                          sectionsSpace: totalCalories == 0 ? 0 : 3,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      flex: 1,
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
                            Text('$totalCarbToStr g',
                                style: TextStyle(fontSize: 11)),
                          ]),
                          TableRow(
                              children: [SizedBox(height: 10), SizedBox()]),
                          TableRow(children: [
                            Text('단백질',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600)),
                            Text('$totalProteinToStr g',
                                style: TextStyle(fontSize: 11)),
                          ]),
                          TableRow(
                              children: [SizedBox(height: 10), SizedBox()]),
                          TableRow(children: [
                            Text('지방',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600)),
                            Text('$totalFatToStr g',
                                style: TextStyle(fontSize: 11)),
                          ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Table(children: [
              TableRow(children: [
                Text(
                  '총',
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ]),
              TableRow(children: [
                Text('$totalCaloriesToStr',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center),
              ]),
              TableRow(children: [
                Text('kcal',
                    style: TextStyle(fontSize: 12),
                    textAlign: TextAlign.center),
              ])
            ]),
          ],
        ));
  }
}
