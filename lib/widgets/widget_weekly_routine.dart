import 'package:flutter/material.dart';

import '../screen/screen_routine.dart';

class RoutineStatusWidget extends StatefulWidget {
  @override
  _TaskStatusWidgetState createState() => _TaskStatusWidgetState();
}

class _TaskStatusWidgetState extends State<RoutineStatusWidget> {
  int _currentCount = 0;
  final int _maxCount = 7; //최대 나중에 수정하기 (임시) 8개까지 들어감 한줄에 8개

  void _handleTap(int index) {
    setState(() {
      if (index < _currentCount) {
        _currentCount = index;
      } else if (_currentCount < _maxCount) {
        _currentCount++;
      }
    },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _indicators = List.generate(_maxCount, (index) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: GestureDetector(
          onTap: () => _handleTap(index),
          child: CircleAvatar(
            radius: 12,
            backgroundColor:
            index < _currentCount ? Color(0xFFFF7070) : Color(0xFFD9D9D9),
          ),
        ),
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              child: Text(
                '습관 만들기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RoutineScreen()),
                );
              },
            ),

            Text(
              '3월 첫째 주',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFFF2F2F2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              SizedBox(width: 5),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RoutineScreen()),
                  );
                },
                child:
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 13, horizontal: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('test', style: TextStyle(fontSize: 12),),
                      Text('$_currentCount/$_maxCount'),
                    ],
                  ),
                ),
              ),
              Container(width: 1,height: 30,color: Colors.grey,),
              SizedBox(width: 10),
              Row(
                children: _indicators,
                mainAxisAlignment: MainAxisAlignment.start,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
