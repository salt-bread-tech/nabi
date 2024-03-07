import 'package:flutter/material.dart';

class ScheduleWidget extends StatelessWidget {
  final int startTime;
  final String content;

  const ScheduleWidget({
    required this.startTime,
    required this.content,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // decoration: BoxDecoration(
      //   color: Color(0xFFFFEBEB),
      //   borderRadius: BorderRadius.circular(10.0),
      // ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: IntrinsicHeight(
          child: Row(
            // crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 시간 위젯
              _Time(
                startTime: startTime,
              ),
              SizedBox(width: 8.0),
              Text('|'),
              SizedBox(width: 8.0),
              // 일정 내용 위젯
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

///////////////
// 자식 위젯들 생성

// 시간을 표시할 위젯 생성
class _Time extends StatelessWidget {
  final int startTime; // 시작 시간

  const _Time({
    required this.startTime,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14.0,
    );

    return Column(
      // 일정을 세로로 배치
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          // 숫자가 한 자리면 0으로 채워기
          '${startTime.toString().padLeft(2, '0')}:00',
          style: textStyle,
        ),
      ],
    );
  }
}

// 내용을 표시할 위젯
class _Content extends StatelessWidget {
  final String content; // 내용

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
      // 최대한 넓게 늘리기
      child: Text(
        content,
        style: textStyle,
      ),
    );
  }
}
