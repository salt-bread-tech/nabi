import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

import '../services/service_routine.dart';



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
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(Duration(days: 7));
  final FocusNode _focusNode = FocusNode();
  int _selectedFrequencyValue = 1;
  bool _showDatePicker = false;
  bool _isStartDatePicker = false;
  late DateTime _selectedDate;


  Future<void> _registerRoutine() async {
    try {
      int userUid = 1; //임시
      int routineId = 1; //임시
      int maxPerform = _selectedFrequencyValue;

      await registerDailyRoutine(
        userUid: userUid,
        routineId: routineId,
        startDate: _startDate,
        endDate: _endDate,
        maxPerform: maxPerform,
      );

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("데일리 루틴 등록 성공")));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("데일리 루틴 등록 실패: $e")));
    }
  }


  void _toggleDatePicker(bool isStartDate) {
    setState(() {
      _showDatePicker = !_showDatePicker;
      if (isStartDate) {
        _selectedDate = _startDate;
      } else {
        _selectedDate = _endDate;
      }
      _isStartDatePicker = isStartDate;
    });
  }

  void _onDateSelected(DateTime newDate) {
    if (_isStartDatePicker) {
      if (newDate.isAfter(_endDate)) {
        return;
      }
      setState(() {
        _startDate = newDate;
      });
    } else {
      if (newDate.isBefore(_startDate)) {
        return;
      }
      setState(() {
        _endDate = newDate;
      });
    }
  }



  Widget _buildDateField(BuildContext context, String label, DateTime date, bool isStartDate) {
    return GestureDetector(
      onTap: () {
        _focusNode.unfocus();
        _toggleDatePicker(isStartDate);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 16),
            ),
            Text(
              DateFormat('yyyy-MM-dd').format(date),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
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
                child: Text('${index + 1}'), //10까지
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

  Color _selectedColor = Color(0xFFFFDFEB);
  final List<Color> _colorOptions = [
    Color(0xFFFFDFEB),
    Color(0xFFFFAAD3),
    Color(0xFFFFF27F),
    Color(0xFFD3EAFF),
    Color(0xFF6696DE),
    Color(0xFFE8DAFF),
    Color(0xFF9D79D8),
  ];

  Widget _buildColorPicker() {
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
                color: isSelected ? Colors.black : Colors.transparent,
                width: 1,
              ),
            ),
            child: CircleAvatar(
              backgroundColor: color,
              radius: 12,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus(); // Automatically focus the text field when the widget is built.
    });
  }

  @override
  void dispose() {
    _routineController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final double datePickerHeight = 300;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20.0),
              children: [
                Text('습관명'),
                TextField(
                  focusNode: _focusNode,
                  autocorrect: false, // 자동완성 기능 끄기
                  decoration: InputDecoration(
                    hintText: '습관명 입력하기',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only( bottom: 11, top: 11, right: 15),
                  ),
                  controller: _routineController,
                ),
                Row(
                  children: [
                    _buildFrequencyDisplay(context),
                    SizedBox(width: 10),
                    _buildColorPicker(),
                    IconButton(onPressed: _registerRoutine, icon: Icon(Icons.send))
                  ],
                )
              ],
            ),
          ),
          if (_showDatePicker)
            Container(
              height: datePickerHeight,
              color: Colors.white,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _isStartDatePicker ? _startDate : _endDate,
                onDateTimeChanged: (DateTime newDate) {
                  _onDateSelected(newDate);
                },
              ),
            ),

        ],
      ),
    );
  }
}