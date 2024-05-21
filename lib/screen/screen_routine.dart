import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../services/globals.dart' as globals;
import '../services/urls.dart';
import '../widgets/widget_addRoutines.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class RoutineScreen extends StatefulWidget {
  @override
  _RoutineScreenState createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  DateTime? _selectedDate;
  List<dynamic> _routines = [];
  String _selectedDateRange = '';

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
        setState(() {
          _routines = json.decode(decodedResponse);
        });
      } else {
        throw Exception('루틴 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('루틴 조회 실패: $e');
    }
  }

  Future<void> fetchWeekRoutines(DateTime date) async {
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final url = Uri.parse('$baseUrl/routine/$formattedDate');
    try {
      final response = await http.get(url, headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${globals.token}',
      });
      if (response.statusCode == 200) {
        setState(() {
          _routines = json.decode(utf8.decode(response.bodyBytes));
          _selectedDateRange = _formatDateRange(date);
        });
        print('루틴 불러오기 성공');
        print(formattedDate);
      } else {
        throw Exception('루틴 불러오기 실패 $formattedDate');
      }
    } catch (e) {
      print('루틴 불러오기 실패 error: $e, $formattedDate');
    }
  }

  String _formatDateRange(DateTime date) {
    int weekday = date.weekday;
    DateTime startOfWeek = date.subtract(Duration(days: weekday - 1));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
    return '${DateFormat('M.dd').format(startOfWeek)}~${DateFormat('M.dd').format(endOfWeek)}';
  }

  void _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && (_selectedDate == null || pickedDate != _selectedDate)) {
      fetchWeekRoutines(pickedDate).then((_) {
        setState(() {
          _selectedDate = pickedDate;
          _selectedDateRange = _formatDateRange(pickedDate);
        });
      });
    }
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
        title: Text(_selectedDateRange.isEmpty
            ? '습관 만들기'
            : '습관 만들기 ($_selectedDateRange)' ,style: TextStyle(fontSize: 15),),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: _presentRoutineAddSheet),
          IconButton(icon: Icon(Icons.calendar_today), onPressed: _selectDate),
        ],
      ),
      body: _routines.isEmpty
          ? Center(child: CircularProgressIndicator())
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
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => onDelete(routine['id']),
            backgroundColor: Color(0xFFFF5050),
            foregroundColor: Colors.white,
            icon: Iconsax.trash,
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
          tileColor: Color(0xFFF2F2F2),
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
