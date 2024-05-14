import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:timelines/timelines.dart';

import '../assets/theme.dart';
import '../services/globals.dart';
import '../services/urls.dart';
import '../widgets/widget_schedule_modal.dart';

class ScheduleCalendar extends StatefulWidget {
  @override
  _ScheduleCalendarState createState() => _ScheduleCalendarState();
}

class _ScheduleCalendarState extends State<ScheduleCalendar> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String datetime = 'today';
  Map<DateTime, List> _eventsList = {};


  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    datetime = DateFormat('yyyy-MM-dd').format(_selectedDay);

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

    for (var key in data.keys) {
      for (var jsonItem in data[key]) {
        DateTime datetime = DateTime.parse(jsonItem['date']);
        String text = jsonItem['text'];
        String schedule =
            "${datetime.hour.toString().padLeft(2, '0')}:${datetime.minute.toString().padLeft(2, '0')} | $text";
        if (_eventsList[DateTime.parse(key)] == null) {
          _eventsList[DateTime.parse(key)] = [];
        }
        _eventsList[DateTime.parse(key)]!.add(schedule);

        _eventsList[DateTime.parse(key)]!.sort((a, b) {
          return a.substring(0, 5).compareTo(b.substring(0, 5));
        });
      }
    }
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
              showAddScheduleModal(context);
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
                      return Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                          getEventForDay(_selectedDay)[index],
                          style: TextStyle(fontSize: 14),
                        ),
                      );
                    },
                    itemCount: getEventForDay(_selectedDay).length,
                  ))),
        ],
      ),
    );
  }
}
