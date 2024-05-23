
import 'package:doctor_nyang/screen/screen_login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../services/service_auth.dart';
import '../widgets/widget_bodyInfo.dart';
import 'package:url_launcher/url_launcher.dart';


class SettingsScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24,vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              //padding: EdgeInsets.only(left: 15),
              child: Text('로그인 / 회원 정보', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Divider(),
            /*SwitchListTile(
              contentPadding: EdgeInsets.only(left:5),
              title: Text('기능1', style: TextStyle(fontSize: 14)),
              value: true,
              onChanged: (bool newValue) {},
            ),

             */
            settingList(title: '신체 정보 수정하기', onTap: (){
              fetchUserInfo();
              showDialog(
                context: context,
                builder: (BuildContext context) => BodyInfoEditorDialog(),
              );
            }),
            settingList(title: '웹툰 다시 보기', onTap: () {  Navigator.pushNamed(context, '/webtoon'); },),
            settingList(
              title: '로그아웃',
              onTap: () {
                showCupertinoDialog(
                  context: context,
                  builder: (BuildContext context) => LogoutConfirmDialog(),
                ); },),
            settingList(
              title: '회원 탈퇴',
              onTap: () {
                showCupertinoDialog(
                  context: context,
                  builder: (BuildContext context) => deletionConfirmDialog(),
                ); },),
            settingList(title: '개인정보 처리방침', onTap: (){
              _launchPrivacyPolicyUrl();
            }),
            Divider(),
          ],
        ),
      ),
    );
  }
}

void _launchPrivacyPolicyUrl() async {
  const url = 'https://betterjeong.notion.site/8ee47ca98af64da09be8f98231a59c7a';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}


class LogoutConfirmDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text('로그아웃'),
      content: Text('로그아웃하시겠습니까?'),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text('취소'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        CupertinoDialogAction(
          child: Text('로그아웃'),
          isDestructiveAction: true,
          onPressed: () {
            logoutUser();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            );
            Navigator.popAndPushNamed(context, '/login');
          },
        ),
      ],
    );
  }
}

class deletionConfirmDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text('회원 탈퇴'),
      content: Text('탈퇴하시겠습니까?'),
      actions: <Widget>[
        CupertinoDialogAction(
          child: Text('취소'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        CupertinoDialogAction(
          child: Text('탈퇴'),
          isDestructiveAction: true,
          onPressed: () {
            withdrawUser();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Login()),
            );
            Navigator.popAndPushNamed(context, '/intro');
          },
        ),
      ],
    );
  }
}

class settingList extends StatelessWidget{
  final String title;
  final VoidCallback onTap;

  const settingList({
    Key? key,
    required this.title,
    required this.onTap,
  }):super(key: key);

  @override
  Widget build(BuildContext context){
    return ListTile(
      contentPadding: EdgeInsets.only(left:5),
      title: Text(title,style: TextStyle(fontSize: 14)),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 15),
      onTap: onTap,
    );
  }
}