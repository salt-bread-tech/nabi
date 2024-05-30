import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import '../services/urls.dart';
import '../services/globals.dart' as globals;
import 'package:http/http.dart' as http;

class RoutineListWidget extends StatefulWidget {
  final String datetime;

  RoutineListWidget({Key? key, required this.datetime}) : super(key: key);

  @override
  _RoutineListWidgetState createState() => _RoutineListWidgetState();
}

class _RoutineListWidgetState extends State<RoutineListWidget> {
  late Future<void> _routinesFuture;
  List<dynamic> _routines = [];

  late DateTime selectedDate;
  String _selectedDateRange = '';
  int _weekNumber = 0;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.parse(widget.datetime);
    _selectedDateRange = _formatDateRange(selectedDate);
    _weekNumber = getWeekNumber(selectedDate);
    _routinesFuture = _fetchRoutines();
  }

  Future<void> _fetchRoutines() async {
    final url = Uri.parse('$baseUrl/routine/date/${widget.datetime}');
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${globals.token}',
      });

      final decodedResponse = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        setState(() {
          _routines = json.decode(decodedResponse);
        });
        print('루틴 조회 성공: ${_routines.length}개');
      } else {
        throw Exception('루틴 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('루틴 조회 실패: $e');
    }
  }

  Future<void> _deleteRoutine(int routineId) async {
    final url = Uri.parse('$baseUrl/routine/$routineId');
    try {
      final response = await http.delete(url, headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${globals.token}',
      });

      if (response.statusCode == 200) {
        _fetchRoutines();
      } else {
        throw Exception('Failed to delete routine');
      }
    } catch (e) {
      print('Failed to delete routine: $e');
    }
  }

  void _handleTap(int index, Map routine) async {
    bool updated = await _updateRoutineCount(
        routine['id'], index, routine['counts'], routine['max']);
    if (updated) {
      setState(() {
        routine['counts'] =
            index < routine['counts'] ? index : routine['counts'] + 1;
      });
    }
  }

  Future<bool> _updateRoutineCount(
      int routineId, int indexClicked, int currentCount, int maxCount) async {
    int newCount = currentCount;
    if (indexClicked < currentCount) {
      newCount = indexClicked;
    } else if (currentCount < maxCount) {
      newCount++;
    }

    final url = Uri.parse('$baseUrl/routine');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${globals.token}',
        },
        body: json.encode({'rid': routineId, 'counts': newCount}),
      );

      if (response.statusCode == 200) {
        print('루틴 횟수 변경 성공, new counts: $newCount');
        return true;
      } else {
        print('루틴 횟수 변경 실패: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('루틴 횟수 변경 실패: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Set a dynamic font size based on the screen width
    final fontSize = MediaQuery.of(context).size.width * 0.034;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: FutureBuilder(
        future: _routinesFuture,
        builder: (context, snapshot) {
          List<Widget> children = [
            Container(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                  Container(
                      padding: EdgeInsets.only(left: 5),
                      margin: EdgeInsets.only(bottom: 10),
                      child: Text(
                        '습관 만들기',
                      )),
                  Container(
                      padding: EdgeInsets.only(right: 5),
                      margin: EdgeInsets.only(bottom: 10),
                      child: Text(
                        '${selectedDate.month}월 ${_weekNumber}주차',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      )),
                ])),
          ];

          if (snapshot.connectionState == ConnectionState.waiting) {
            children.add(
              Container(
                margin: EdgeInsets.all(5),
                width: double.infinity,
                child: Text('습관을 불러오는 중입니다...'),
              ),
            );
          } else if (!snapshot.hasData && _routines.isEmpty) {
            children.add(
              Container(
                margin: EdgeInsets.all(5),
                width: double.infinity,
                child: Text('등록된 습관이 없습니다.'),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done) {
            children.addAll(
              _routines.map((routine) {
                return RoutineItem(
                  routine: routine,
                  onDelete: (id) => _deleteRoutine(id),
                  onCountChange: (circleIndex) =>
                      _handleTap(circleIndex, routine),
                );
              }).toList(),
            );
          } else {
            children.add(
              Container(
                margin: EdgeInsets.all(5),
                width: double.infinity,
                child: Text('습관을 불러오는 중 오류가 발생했습니다.'),
              ),
            );
          }

          return Column(
            children: children,
          );
        },
      ),
    );
  }
}

String _formatDateRange(DateTime date) {
  int weekday = date.weekday;
  DateTime startOfWeek = date.subtract(Duration(days: weekday - 1));
  DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
  return '${DateFormat('M.dd').format(startOfWeek)}~${DateFormat('M.dd').format(endOfWeek)}';
}

int getWeekNumber(DateTime date) {
  DateTime firstOfMonth = DateTime(date.year, date.month, 1);
  int dayOfWeek = firstOfMonth.weekday;
  DateTime firstDayOfFirstWeek = firstOfMonth.subtract(Duration(days: dayOfWeek - 1));
  int weekNumber = ((date.difference(firstDayOfFirstWeek).inDays) ~/ 7) + 1;
  return weekNumber;
}
class RoutineItem extends StatelessWidget {
  final Map routine;
  final Function(int) onDelete;
  final Function(int) onCountChange;

  const RoutineItem({
    Key? key,
    required this.routine,
    required this.onDelete,
    required this.onCountChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final fontSize = screenSize.width * 0.03; // 화면 너비에 비례하여 폰트 크기 설정

    int currentCount = routine['counts'];
    int maxCount = routine['max'];
    String routineName = routine['name'];
    String colorCode = routine['color'];

    return GestureDetector(
      onTap: () {
        // Handle navigation tap here
      },
      child: Slidable(
        key: Key(routine['id'].toString()),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          color: Color(0xFFF6F6F6),
          elevation: 0,
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(routineName, style: TextStyle(fontSize: fontSize)),
                      SizedBox(height: 1),
                      Text(
                        '$currentCount/$maxCount',
                        style: TextStyle(fontSize: fontSize, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: List.generate(maxCount, (index) {
                      return GestureDetector(
                        onTap: () => onCountChange(index),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1.5),
                          height: 23,
                          width: 23,
                          decoration: BoxDecoration(
                            color: index < currentCount
                                ? Color(int.parse("0xFF$colorCode"))
                                : Color(0xFFD9D9D9),
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
