import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import '../widgets/widget_bodyInfo.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            SwitchListTile(
              title: Text('기능1', style: TextStyle(fontSize: 14)),
              value: true,
              onChanged: (bool newValue) {},
            ),
            ListTile(
              title: Text('신체 정보 수정하기', style: TextStyle(fontSize: 14)),
              trailing: Icon(Icons.arrow_forward_ios_rounded, size: 15),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => BodyInfoEditorDialog(),
                );
              },
            ),
            ListTile(
              title: Text('튜토리얼 다시 보기', style: TextStyle(fontSize: 14)),
              trailing: Icon(Icons.arrow_forward_ios_rounded, size: 15),
              onTap: () {},
            ),
            ListTile(
              title: Text('로그아웃', style: TextStyle(fontSize: 14)),
              trailing: Icon(Icons.arrow_forward_ios_rounded, size: 15),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
