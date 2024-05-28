import 'dart:convert';
import 'package:doctor_nyang/widgets/widget_delete.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/globals.dart' as globals;
import '../services/urls.dart';
import '../widgets/widget_addRoutines.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../assets/theme.dart';

class RoutineScreen extends StatefulWidget {
  @override
  _RoutineScreenState createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  DateTime? _selectedDate;
  List<dynamic> _routines = [];
  String _selectedDateRange = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _selectedDateRange = _formatDateRange(_selectedDate!);
    fetchRoutines();
  }

  void refreshRoutines() {
    fetchRoutines();
  }

  void _presentRoutineAddSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => AddRoutineWidget(onRoutineAdded: refreshRoutines),
    );
  }

  Future<void> fetchRoutines() async {
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse('$baseUrl/routine');
    try {
      final response = await http.get(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${globals.token}',
        },
      );

      final decodedResponse = utf8.decode(response.bodyBytes);

      if (response.statusCode == 200) {
        print('루틴 조회 성공');
        final responseJson = json.decode(decodedResponse);
        setState(() {
          _routines = responseJson.isNotEmpty ? responseJson : [];
          _isLoading = false;
        });
      } else {
        throw Exception('루틴 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('루틴 조회 실패: $e');
      setState(() {
        _routines = [];
        _isLoading = false;
      });
    }
  }

  Future<void> fetchWeekRoutines(DateTime date) async {
    setState(() {
      _isLoading = true;
    });

    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final url = Uri.parse('$baseUrl/routine/$formattedDate');
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${globals.token}',
      });
      if (response.statusCode == 200) {
        final responseJson = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _routines = responseJson.isNotEmpty ? responseJson : [];
          _selectedDateRange = _formatDateRange(date);
          _isLoading = false;
        });
        print('루틴 불러오기 성공');
        print(formattedDate);
      } else {
        throw Exception('루틴 불러오기 실패 $formattedDate');
      }
    } catch (e) {
      print('루틴 불러오기 실패 error: $e, $formattedDate');
      setState(() {
        _routines = [];
        _isLoading = false;
      });
    }
  }

  String _formatDateRange(DateTime date) {
    int weekday = date.weekday;
    DateTime startOfWeek = date.subtract(Duration(days: weekday - 1));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
    return '${DateFormat('M.dd').format(startOfWeek)}~${DateFormat('M.dd').format(endOfWeek)}';
  }

  void _selectDate() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return WidgetCalendarMonth(
          onDateSelected: (selectedDate) {
            fetchWeekRoutines(selectedDate).then((_) {
              setState(() {
                _selectedDate = selectedDate;
                _selectedDateRange = _formatDateRange(selectedDate);
              });
            });
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _handleTap(int index, Map routine) async {
    bool updated = await _updateRoutineCount(routine['id'], index, routine['counts'], routine['max']);
    if (updated) {
      setState(() {
        routine['counts'] = index < routine['counts'] ? index : routine['counts'] + 1;
      });
    }
  }

  Future<bool> _updateRoutineCount(int routineId, int indexClicked, int currentCount, int maxCount) async {
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

  Future<bool> deleteRoutine(int routineId) async {
    final url = Uri.parse('$baseUrl/routine/$routineId');
    try {
      final response = await http.delete(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${globals.token}',
        },
      );

      if (response.statusCode == 200) {
        print('루틴 삭제 성공');
        fetchRoutines();
        return true;
      } else {
        throw Exception('루틴 삭제 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('루틴 삭제 실패: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedDateRange.isEmpty
              ? '습관 만들기'
              : '습관 만들기 ($_selectedDateRange)',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: _presentRoutineAddSheet),
          IconButton(icon: Icon(Icons.calendar_today), onPressed: _selectDate),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _routines.isEmpty
          ? Center(child: Text('루틴 없음'))
          : ListView.builder(
        itemCount: _routines.length,
        itemBuilder: (context, index) {
          final routine = _routines[index];
          return RoutineItem(
            routine: routine,
            onDelete: (id) => deleteRoutine(id),
            onCountChange: (circleIndex) => _handleTap(circleIndex, routine),
          );
        },
      ),
    );
  }
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
    int currentCount = routine['counts'];
    int maxCount = routine['max'];
    String routineName = routine['name'];
    String colorCode = routine['color'];

    return Slidable(
      key: Key(routine['id'].toString()),
      endActionPane: ActionPane(
        extentRatio: 0.2,
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            flex: 1,
            onPressed: (context) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return DeleteConfirmDialog(
                    title: '삭제 확인',
                    content: '이 항목을 삭제하시겠습니까?',
                    onConfirm: () {
                      onDelete(routine['id']);
                    },
                  );
                },
              );
            },
          //=> onDelete(routine['id']),
            backgroundColor: Color(0xFFFF5050),
            foregroundColor: Colors.white,
            icon: Iconsax.trash,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          tileColor: Color(0xFFF6F6F6),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(routineName, style: TextStyle(fontSize: 12)),
                  SizedBox(height: 1),
                  Text(
                    '$currentCount/$maxCount',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(width: 0),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(maxCount, (index) {
              return GestureDetector(
                onTap: () => onCountChange(index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                    color: index < currentCount ? Color(int.parse("0xFF$colorCode")) : Color(0xFFD9D9D9),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class WidgetCalendarMonth extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  WidgetCalendarMonth({required this.onDateSelected});

  @override
  _WidgetCalendarMonthState createState() => _WidgetCalendarMonthState();
}

class _WidgetCalendarMonthState extends State<WidgetCalendarMonth> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String datetime = 'today';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          locale: 'ko_KR',
          firstDay: DateTime.utc(2000, 1, 1),
          lastDay: DateTime.utc(2101, 12, 31),
          focusedDay: _focusedDay,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            rightChevronIcon: Icon(
              Icons.keyboard_arrow_right,
              size: 20.0,
              color: Colors.black,
            ),
            leftChevronIcon: Icon(
              Icons.keyboard_arrow_left,
              size: 20.0,
              color: Colors.black,
            ),
          ),
          calendarStyle: const CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: AppTheme.pastelBlue,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: AppTheme.pastelYellow,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: TextStyle(color: Colors.white),
            todayTextStyle: TextStyle(color: Colors.black),
            canMarkersOverflow: false,
            markersAutoAligned: true,
            markerSize: 5.0,
            markersMaxCount: 4,
            markerDecoration: BoxDecoration(
              color: AppTheme.pastelPink,
              shape: BoxShape.circle,
            ),
          ),
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
            widget.onDateSelected(selectedDay);
          },
          calendarFormat: CalendarFormat.month,
        ),
      ],
    );
  }
}
