import 'package:doctor_nyang/services/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../assets/theme.dart';

class WidgetCalendar2 extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final GlobalKey<WidgetCalendarState> calendarKey;
  final DateTime initialSelectedDate;

  WidgetCalendar2({
    required this.onDateSelected,
    required this.calendarKey,
    required this.initialSelectedDate,
  }) : super(key: calendarKey);

  @override
  WidgetCalendarState createState() => WidgetCalendarState();
}

class WidgetCalendarState extends State<WidgetCalendar2> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialSelectedDate;
    _focusedDay = widget.initialSelectedDate;
  }

  void updateSelectedDay(DateTime newDate) {
    setState(() {
      _selectedDay = newDate;
      _focusedDay = newDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TableCalendar(
          locale: 'ko_KR',
          firstDay: DateTime.utc(2000, 1, 1),
          lastDay: DateTime.utc(2101, 12, 31),
          focusedDay: _focusedDay,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: TextStyle(fontSize: 15),
            headerPadding: EdgeInsets.only(bottom: 10),
            leftChevronVisible: false,
            rightChevronVisible: false,
          ),
          calendarStyle: const CalendarStyle(
            selectedDecoration: BoxDecoration(
              color: Color(0xFFAED3FA),
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: AppTheme.pastelYellow,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600),
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
                    shape: BoxShape.circle,
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
}
