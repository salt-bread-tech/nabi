import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../services/globals.dart' as globals;
import '../services/urls.dart';
import '../widgets/widget_addRoutines.dart';


class RoutineScreen extends StatefulWidget {
  @override
  _RoutineScreenState createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  void _presentRoutineAddSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => AddRoutineWidget(),
    );
  }

  List<dynamic> _routines = [];

  @override
  void initState() {
    super.initState();
    fetchRoutines();
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
      } else if (response.statusCode == 400) {
        print('사용자 정보를 찾을 수 없음');
      } else {
        throw Exception('루틴 조회 실패: ${response.statusCode}');
      }
    } catch (e) {
      print('루틴 조회 실패: $e');
    }
  }


  Widget _buildRoutineItem(Map routine) {
    int currentCount = routine['counts'];
    int maxCount = routine['max'];
    String routineName = routine['name'];
    String colorCode = routine['color'];
    return ListTile(
      shape: RoundedRectangleBorder( //<-- SEE HERE
        borderRadius: BorderRadius.circular(10),
      ),
      tileColor: Color(0xFFF2F2F2),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(routineName, style: TextStyle(fontSize: 13)),
                SizedBox(height: 1),
                Text(
                  '$currentCount/$maxCount',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ]
          ),

          SizedBox(width: 10),
          Container(
            width: 0.5,
            height: 40,
            color: Colors.grey,
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(maxCount, (index) {
          return GestureDetector(
            onTap: () async {
              bool updated = await _updateRoutineCount(routine['id'], routine['counts']);
              if (updated) {
                setState(() {
                  if (index < routine['counts']) {
                    routine['counts'] = index;
                  } else if (routine['counts'] < routine['max']) {
                    routine['counts']++;
                  }
                });
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
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
    );
  }


  Future<bool> _updateRoutineCount(int routineId, int newCount) async {
    final url = Uri.parse('$baseUrl/routine');
    try {
      final response = await http.put(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${globals.token}',
        },
        body: json.encode({'rid': routineId, 'counts': newCount+1}),
      );

      if (response.statusCode == 200) {
        print('루틴 횟수 변경, counts: $newCount');
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


  Widget _buildRoutineList() {
    return ListView.builder(
      itemCount: _routines.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
          child: _buildRoutineItem(_routines[index]),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('습관 만들기', style: TextStyle(fontSize: 18)),
        actions: [
          IconButton(onPressed: _presentRoutineAddSheet, icon: Icon(Icons.add))
        ],
      ), body: _routines.isEmpty
        ? Center(child: CircularProgressIndicator())
        : _buildRoutineList(),
    );
  }
}

