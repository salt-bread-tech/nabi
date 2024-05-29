import 'dart:async';
import 'dart:convert';
import 'package:doctor_nyang/screen/screen_diet_schedule.dart';
import 'package:doctor_nyang/screen/screen_dosage_schedule.dart';
import 'package:doctor_nyang/screen/screen_login.dart';
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
  String _selectedDateRange = '';

  void _handleDateChange(DateTime newDate) {
    setState(() {
      selectedDate = newDate.toUtc();
    });
  }

  void refreshData() {
    setState(() {
      selectedDate = selectedDate.toUtc();
      _selectedDateRange = _formatDateRange(selectedDate.toUtc());
    });
  }

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now().toUtc();
    _selectedDateRange = _formatDateRange(selectedDate.toUtc());
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 10,
        backgroundColor: Colors.white,
        leading: Container(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(children: <Widget>[
            SizedBox(height: 20),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 15),
            ),
            WidgetCalendar(onDateSelected: _handleDateChange),
            SizedBox(height: 20),
            ReorderableColumn(),
          ]),
        ),
      ),
    );
  }
}

class ReorderableColumn extends StatefulWidget {
  @override
  _ReorderableColumnState createState() => _ReorderableColumnState();
}

class _ReorderableColumnState extends State<ReorderableColumn> {
  int selectedTab = 0;
  late DateTime selectedDate;
  List<dynamic> ingestionSchedule = [];

  List<dynamic> _usedWidgets = [];
  List<dynamic> _unusedWidgets = [];
  List<String> _usedWidgetKeys = [];
  List<String> _unusedWidgetKeys = [];
  Map<String, bool> _showButtons = {};

  void refreshData() {
    setState(() {
      selectedDate = selectedDate.toUtc();
      fetchIngestion();
    });
  }

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now().toUtc();
    fetchIngestion();
    fetchUserInfo();
    getWidgetOrder();
  }

  Future<void> _showNetworkErrorDialog() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('네트워크 오류'),
          content: Text('인터넷에 연결되지 않았습니다. \n 확인을 누르면 로그아웃됩니다.'),
          actions: [
            TextButton(
              child: Text('확인'),
              onPressed: () async {
                Navigator.of(context).pop();
                await logoutUser();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  FutureOr<Ingestion?> fetchIngestion() async {
    final String formattedDate =
        DateFormat('yyyy-MM-dd').format(selectedDate.toUtc());
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
      _showNetworkErrorDialog();
    }
  }

  Future<void> getWidgetOrder() async {
    final url = Uri.parse('$baseUrl/home/widget');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final usedKeys = data['used'] == null ? [''] : data['used'].split('');
      final unusedKeys =
          data['unused'] == null ? [''] : data['unused'].split('');

      print('usedKeys: $usedKeys');
      print('unusedKeys: $unusedKeys');

      setState(() {
        _usedWidgetKeys = usedKeys;
        _unusedWidgetKeys = unusedKeys;
        _usedWidgets =
            usedKeys.map((key) => _buildWidgetByKey(key, true)).toList();
        _unusedWidgets =
            unusedKeys.map((key) => _buildWidgetByKey(key, false)).toList();
        for (String key in usedKeys + unusedKeys) {
          _showButtons[key] = false;
        }
      });
    } else {
      throw Exception('위젯 순서 조회 실패');
    }
  }

  Widget ScheduleWidget({required bool isActive}) {
    return GestureDetector(
      key: ValueKey('0'),
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
              child: Text('일정'),
            ),
            WidgetSchedule(
              datetime: selectedDate.toUtc().toString(),
              isWidget: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget IngestionWidget({required bool isActive}) {
    return GestureDetector(
      key: ValueKey('1'),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DietSchedule()),
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
              child: Text('식단'),
            ),
            WidgetDiet(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DietSchedule()),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget RoutineWidget({required bool isActive}) {
    return GestureDetector(
      key: ValueKey('2'),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RoutineScreen(selectedDate: selectedDate)),
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
                key: ValueKey(
                    DateFormat('yyyy-MM-dd').format(selectedDate.toUtc())),
                datetime: DateFormat('yyyy-MM-dd').format(selectedDate.toUtc()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget PrescriptionWidget({required bool isActive}) {
    return GestureDetector(
      key: ValueKey('3'),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PrescriptionScreen()),
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
              child: Text('처방전'),
            ),
            WidgetPrescription(
              datetime: DateFormat('yyyy-MM-dd').format(selectedDate.toUtc()),
            ),
          ],
        ),
      ),
    );
  }

  Widget DosageWidget({required bool isActive}) {
    return GestureDetector(
      key: ValueKey('4'),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DosageSchedule(selectedDate: selectedDate)),
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
              child: Text('의약품 복용 일정'),
            ),
            WidgetDosage(
              datetime: DateFormat('yyyy-MM-dd').format(selectedDate.toUtc()),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> editWidgetOrder() async {
    final url = Uri.parse('$baseUrl/home/widget');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'used': _usedWidgetKeys.join(''),
        'unused': _unusedWidgetKeys.join('')
      }),
    );

    if (response.statusCode == 200) {
      print('위젯 순서 수정 성공');
    } else {
      throw Exception('위젯 순서 수정 실패');
    }
  }

  Widget _buildWidgetByKey(String key, bool isActive) {
    switch (key) {
      case '0':
        return _buildOverlayedWidget(
            ScheduleWidget(isActive: isActive), key, isActive);
      case '1':
        return _buildOverlayedWidget(
            IngestionWidget(isActive: isActive), key, isActive);
      case '2':
        return _buildOverlayedWidget(
            RoutineWidget(isActive: isActive), key, isActive);
      case '3':
        return _buildOverlayedWidget(
            PrescriptionWidget(isActive: isActive), key, isActive);
      case '4':
        return _buildOverlayedWidget(
            DosageWidget(isActive: isActive), key, isActive);
      default:
        return Container();
    }
  }

  Widget _buildOverlayedWidget(Widget widget, String key, bool isActive) {
    return Stack(
      children: [
        widget,
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: Icon(isActive ? Icons.remove_circle : Icons.add_circle, color: Colors.grey.withOpacity(0.1)),
            onPressed: () => _toggleWidget(key),
          ),
        ),
      ],
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Widget item = _usedWidgets.removeAt(oldIndex);
      _usedWidgets.insert(newIndex, item);
      final String key = _usedWidgetKeys.removeAt(oldIndex);
      _usedWidgetKeys.insert(newIndex, key);
      editWidgetOrder();
    });
  }

  void _toggleWidget(String key) {
    setState(() {
      if (_usedWidgetKeys.contains(key)) {
        final index = _usedWidgetKeys.indexOf(key);
        _usedWidgetKeys.removeAt(index);
        _unusedWidgetKeys.add(key);
        _unusedWidgets.add(_buildWidgetByKey(key, false));
        _usedWidgets.removeAt(index);
      } else {
        final index = _unusedWidgetKeys.indexOf(key);
        _unusedWidgetKeys.removeAt(index);
        _usedWidgetKeys.add(key);
        _usedWidgets.add(_buildWidgetByKey(key, true));
        _unusedWidgets.removeAt(index);
      }
      editWidgetOrder();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReorderableListView(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          children: _usedWidgets.asMap().entries.map((entry) {
            int index = entry.key;
            Widget widget = entry.value;
            return Padding(
              key: ValueKey(_usedWidgetKeys[index]),
              padding: const EdgeInsets.all(8.0),
              child: widget,
            );
          }).toList(),
          onReorder: _onReorder,
        ),
        ..._unusedWidgets.map((widget) {
          int index = _unusedWidgets.indexOf(widget);
          String key = _unusedWidgetKeys[index];
          return Padding(
            key: ValueKey(_unusedWidgetKeys[index]),
            padding: const EdgeInsets.all(8.0),
            child: widget,
          );
        }).toList(),
      ],
    );
  }
}
