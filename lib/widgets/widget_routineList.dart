import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconsax/iconsax.dart';

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
  List<dynamic> _routines = [];

  @override
  void initState() {
    super.initState();
    _fetchRoutines();
  }

  Future<void> _fetchRoutines() async {
    final url = Uri.parse('$baseUrl/routine/${widget.datetime}');
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

  Future<bool> _updateRoutineCount(int routineId, int indexClicked,
      int currentCount, int maxCount) async {
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
    final itemHeight = 70.0;
    final listHeight = _routines.length * itemHeight;

    return Container(
      height: listHeight,
      child: ListView.builder(
        physics: NeverScrollableScrollPhysics(), // 스크롤 방지
        itemCount: _routines.length,
        itemBuilder: (context, index) {
          final routine = _routines[index];
          return RoutineItem(
            routine: routine,
            onDelete: (id) => _deleteRoutine(id),
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

  const RoutineItem({Key? key, required this.routine, required this.onDelete, required this.onCountChange}) : super(key: key);

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
                  ]
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(maxCount, (index) {
              return GestureDetector(
                onTap: () => onCountChange(index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  height: 23,
                  width: 23,
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
