import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../services/globals.dart' as globals;
import '../services/urls.dart';

Future<void> registerDailyRoutine({
  required int userUid,
  required String routineName,
  required int maxPerform,
  required String startDate,
  required String colorCode,
}) async {
  final url = Uri.parse('$baseUrl/routine/register');
  final response = await http.post(
    url,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, dynamic>{
      'uid': userUid,
      'name': routineName,
      'maxPerform': maxPerform,
      'date': startDate,
      'colorCode': colorCode,
    }),
  );

  if (response.statusCode == 200) {
    print('루틴 등록 성공');
  } else if (response.statusCode == 400) {
    print('사용자 정보를 찾을 수 없음');
  } else {
    throw Exception('루틴 등록 실패');
  }
}

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('습관 만들기', style: TextStyle(fontSize: 18)),
        actions: [
          IconButton(onPressed: _presentRoutineAddSheet, icon: Icon(Icons.add))
        ],
      ),
    );
  }
}

class AddRoutineWidget extends StatefulWidget {
  @override
  _AddRoutineWidgetState createState() => _AddRoutineWidgetState();
}

class _AddRoutineWidgetState extends State<AddRoutineWidget> {
  final TextEditingController _routineController = TextEditingController();
  int _selectedFrequencyValue = 1;
  Color _selectedColor = Color(0xFFFFDFEB);
  String startDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  void _registerRoutine() async {
    int? userId = globals.userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("사용자 ID가 없습니다.")));
      return;
    }

    String colorCodeWithoutAlpha = _selectedColor.value.toRadixString(16).substring(2).toUpperCase();

    try {
      await registerDailyRoutine(
          userUid: userId,
          routineName: _routineController.text,
          maxPerform: _selectedFrequencyValue,
          startDate: startDate,
          colorCode: colorCodeWithoutAlpha
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("데일리 루틴 등록 성공")));
      print('userId: ${userId}, Name: ${_routineController.text}, Max Perform: ${_selectedFrequencyValue}, Color: ${colorCodeWithoutAlpha}, Date: ${startDate}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("데일리 루틴 등록 실패: $e")));
    }
  }

  void _showFrequencyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          child: CupertinoPicker(
            backgroundColor: CupertinoColors.white,
            onSelectedItemChanged: (int value) {
              setState(() {
                _selectedFrequencyValue = value + 1;
              });
            },
            itemExtent: 32.0,
            children: List<Widget>.generate(10, (int index) {
              return Center(
                child: Text('${index + 1}'),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildFrequencyDisplay(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFrequencyPicker(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$_selectedFrequencyValue',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    final List<Color> _colorOptions = [
      Color(0xFFFFDFEB),
      Color(0xFFFFAAD3),
      Color(0xFFFFF27F),
      Color(0xFFD3EAFF),
      Color(0xFF6696DE),
      Color(0xFFE8DAFF),
      Color(0xFF9D79D8),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _colorOptions.map((color) {
        bool isSelected = _selectedColor == color;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
          },
          child: Container(
            padding: EdgeInsets.all(1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.grey : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: CircleAvatar(
              backgroundColor: color,
              radius: 13,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20.0),
              children: [
                Text('습관명'),
                TextField(
                  autocorrect: false,
                  decoration: InputDecoration(
                    hintText: '습관명 입력하기',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(bottom: 11, top: 11, right: 15),
                  ),
                  controller: _routineController,
                ),
                Row(
                  children: [
                    _buildFrequencyDisplay(context),
                    SizedBox(width: 30),
                    _buildColorPicker(),
                    Spacer(),
                    IconButton(onPressed: _registerRoutine, icon: Icon(Icons.send))
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
