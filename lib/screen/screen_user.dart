import 'package:flutter/material.dart';

class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // 설정 기능 나중에 넣기
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start, // 새로운 줄
          children: <Widget>[
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey,
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('이름',style: TextStyle(fontSize: 20),),
                    SizedBox(height: 5),
                    Text('111@gmail.com'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('기능 목록',style: TextStyle(fontSize: 16)),
            Divider(),
            ListTile(
              title: Text('약 복용 루틴'), //임시
              onTap: () {
                Navigator.pushNamed(context, '/PillSchedule');
              },
            ),
            ListTile(
              title: Text('약물 추가 화면'), //임시
              onTap: () {
                Navigator.pushNamed(context, '/DosageSearch');
              },
            ),
          ],
        ),
      ),
    );
  }
}
