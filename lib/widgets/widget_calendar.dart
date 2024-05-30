import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:iconsax/iconsax.dart';
import 'package:table_calendar/table_calendar.dart';

import '../assets/theme.dart';

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
          calendarBuilders: CalendarBuilders(
            selectedBuilder: (context, day, focusedDay) {
              return Container(
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.pastelBlue.withOpacity(0.5),
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle().copyWith(),
                    ),
                  ));
            },
            defaultBuilder: (context, day, focusedDay) {
              return Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle().copyWith(),
                ),
              );
            },
            outsideBuilder: (context, day, focusedDay) {
              return Center(
                child: Text(
                  '${day.day}',
                  style: TextStyle().copyWith(color: Colors.grey),
                ),
              );
            },
            todayBuilder: (context, day, focusedDay) {
              return Container(
                  width: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle ,
                    color: AppTheme.pastelYellow,
                  ),
                  child: Center(
                    child: Text(
                      '${day.day}',
                      style: TextStyle().copyWith(),
                    ),
                  ));
            },
          ),
        ),
      ],
    );
  }

  void _showDatePickerPopup(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 400,
          color: Colors.white,
          child: Column(
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
                  Navigator.pop(context);
                },
                calendarFormat: CalendarFormat.month,
              ),
            ],
          ),
        );
      },
    );
  }
}
