import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:table_calendar/table_calendar.dart';

import '../assets/theme.dart';



class WidgetCalendar extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  WidgetCalendar({required this.onDateSelected});

  @override
  _WidgetCalendarState createState() => _WidgetCalendarState();
}

class _WidgetCalendarState extends State<WidgetCalendar> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String datetime = 'today';

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
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
      calendarFormat: CalendarFormat.week,
    );
  }
}