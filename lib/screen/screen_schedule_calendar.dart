import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:timelines/timelines.dart';

import '../assets/theme.dart';
import '../services/globals.dart';
import '../services/urls.dart';

class ScheduleCalendar extends StatefulWidget {
  @override
  _ScheduleCalendarState createState() => _ScheduleCalendarState();
}

class _ScheduleCalendarState extends State<ScheduleCalendar> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String datetime = 'today';
  Map<DateTime, List> _eventsList = {};
  String content = '';
  late DateTime selectedDate;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    datetime = DateFormat('yyyy-MM-dd').format(_selectedDay);
    selectedDate = _selectedDay;
    getSchedule();
  }

  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  Future<void> getSchedule() async {
    final url = Uri.parse('$baseUrl/schedule/$datetime');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final decodedBody = utf8.decode(response.bodyBytes);
    final data = json.decode(decodedBody);

    if (data is int) {
      throw Exception('조회 실패 ${response.statusCode}');
    }

    Map<DateTime, List> newEventsList = {};

    for (var key in data.keys) {
      List schedules = [];
      for (var jsonItem in data[key]) {
        DateTime datetime = DateTime.parse(jsonItem['date']);
        String text = jsonItem['text'];
        int ScheduleId = jsonItem['scheduleId'];
        schedules.add(ScheduleId.toString() +
            ' ' +
            datetime.hour.toString().padLeft(2, '0') +
            ':' +
            datetime.minute.toString().padLeft(2, '0') +
            ' ' +
            text);
      }
      newEventsList[DateTime.parse(key)] = schedules;
    }

    newEventsList.forEach((key, value) {
      value.sort((a, b) {
        return a.split(' ')[1].compareTo(b.split(' ')[1]);
      });
    });

    setState(() {
      _eventsList = newEventsList;
    });
  }

  Future<void> addSchedule() async {
    final String url = '$baseUrl/schedule';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'text': content,
          'date': DateFormat('yyyy-MM-ddTHH:mm:ss').format(_selectedDay),
        }),
      );

      if (response.statusCode == 200) {
        print('Schedule added');
      } else {
        throw Exception('Failed to add schedule');
      }
    } catch (e) {
      print('error: $e');
    }
  }

  Future<void> deleteSchedule(int scheduleId) async {
    final String url = '$baseUrl/schedule/$scheduleId';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('Schedule deleted');
        getSchedule();
      } else {
        throw Exception('Failed to delete schedule');
      }
    } catch (e) {
      print('error: $e');
    }
  }

  void showScheduleModal(BuildContext context, DateTime initialDate) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext buildContext) {
          return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                  width: double.infinity,
                  height: 240,
                  decoration: BoxDecoration(
                    color: AppTheme.appbackgroundColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: '새로운 일정',
                          labelStyle: TextStyle(color: Colors.black),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          content = value;
                        },
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text('날짜', style: TextStyle(color: Colors.black)),
                          TextButton(
                            onPressed: () {
                              showCupertinoModalPopup(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return Container(
                                      height: 300,
                                      color: Colors.white,
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 200,
                                            child: CupertinoDatePicker(
                                              initialDateTime: _selectedDay,
                                              onDateTimeChanged:
                                                  (DateTime newDateTime) {
                                                setState(() {
                                                  _selectedDay = newDateTime;
                                                });
                                              },
                                              use24hFormat: true,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('확인'),
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                            },
                            child: Text(
                                '${_selectedDay.year}년 ${_selectedDay.month}월 ${_selectedDay.day}일 ${_selectedDay.hour}시 ${_selectedDay.minute}분',
                                style: TextStyle(color: Colors.black)),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Container(
                          width: double.infinity,
                          height: 55,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Color(0xFFEBEBEB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              addSchedule();
                              getSchedule();
                              Navigator.of(context).pop();
                              print('Schedule Added: $selectedDate $content');
                            },
                            child: Text('일정 추가',
                                style: TextStyle(color: Colors.black)),
                          )),
                    ],
                  )));
        });
  }

  @override
  Widget build(BuildContext context) {
    final _events = LinkedHashMap<DateTime, List>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(_eventsList);

    List getEventForDay(DateTime day) {
      return _events[day] ?? [];
    }

    getEventForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          '$nickName님의 일정',
          style: TextStyle(color: Colors.black, fontSize: 17),
          textAlign: TextAlign.center,
        ),
        iconTheme: IconThemeData(color: Colors.black),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showScheduleModal(context, _selectedDay);
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          TableCalendar(
            locale: 'ko_KR',
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2101, 12, 31),
            focusedDay: _focusedDay,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(
                Icons.arrow_left,
                size: 0.0,
              ),
              rightChevronIcon: Icon(
                Icons.arrow_right,
                size: 0.0,
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
                datetime = DateFormat('yyyy-MM-dd').format(_selectedDay);
                getEventForDay(_selectedDay);
              });
            },
            calendarFormat: CalendarFormat.month,
            eventLoader: getEventForDay,
          ),
          Expanded(
              child: Timeline.tileBuilder(
                  theme: TimelineThemeData(
                    nodePosition: 0.07,
                    color: AppTheme.pastelBlue,
                    indicatorTheme: IndicatorThemeData(
                      position: 0.5,
                      size: 17.0,
                    ),
                    connectorTheme: ConnectorThemeData(
                      thickness: 2.0,
                    ),
                  ),
                  builder: TimelineTileBuilder.fromStyle(
                    contentsAlign: ContentsAlign.basic,
                    contentsBuilder: (context, index) {
                      return Slidable(
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (context) => {
                                deleteSchedule(int.parse(
                                    getEventForDay(_selectedDay)[index]
                                        .split(' ')[0])),
                              },
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: '삭제',
                            ),
                          ],
                        ),
                        child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppTheme.appbackgroundColor,
                            ),
                            padding: EdgeInsets.all(10),
                            child: Text(
                              getEventForDay(_selectedDay)[index]
                                      .split(' ')[1] +
                                  '  ' +
                                  getEventForDay(_selectedDay)[index]
                                      .split(' ')
                                      .skip(2)
                                      .join(' '),
                              style: TextStyle(fontSize: 14),
                            )),
                      );
                    },
                    itemCount: getEventForDay(_selectedDay).length,
                  ))),
        ],
      ),
    );
  }
}
