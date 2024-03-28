import 'package:flutter/material.dart';

class ScheduleWidget extends StatelessWidget {
  final int time;
  final int minute;
  final String content;

  const ScheduleWidget({
    required this.time,
    required this.minute,
    required this.content,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: IntrinsicHeight(
          child: Row(
            children: [
              _Time(time: time, minute: minute),
              SizedBox(width: 8.0),
              Text('|'),
              SizedBox(width: 8.0),
              _Content(
                content: content,
              ),
              SizedBox(width: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}

class _Time extends StatelessWidget {
  final int time;
  final int minute;

  const _Time({
    required this.time,
    required this.minute,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14.0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${time.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
          style: textStyle,
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  final String content;

  const _Content({
    required this.content,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontWeight: FontWeight.w300,
      fontSize: 14.0,
    );
    return Expanded(
      child: Text(
        content,
        style: textStyle,
      ),
    );
  }
}
