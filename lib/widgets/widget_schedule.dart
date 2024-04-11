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
          child: Text(
            '${time.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} | $content',
          )
        ),
      ),
    );
  }
}