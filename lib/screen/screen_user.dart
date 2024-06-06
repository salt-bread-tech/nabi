import 'package:doctor_nyang/screen/screen_settings.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../services/globals.dart' as globals;
import '../services/service_auth.dart';

class UserScreen extends StatefulWidget {
  @override
  _UserScreenState createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserInfo().then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final fontSize = screenSize.width * 0.036;

    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(Iconsax.setting_2),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(),
                ),
              );
              setState(() {
                fetchUserInfo().then((_) {
                  setState(() {
                    _isLoading = false;
                  });
                });
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(globals.nickName ?? '이름',
                        style: TextStyle(fontSize: 20)),
                    SizedBox(height: 5),
                   /* Text(globals.birth ?? '생년월일',
                        style: TextStyle(fontSize: 12)),
                    Row(
                      children: [
                        Text('${globals.height?.toString() ?? '키'}cm',
                            style: TextStyle(fontSize: 12)),
                        SizedBox(width: 5),
                        Text('${globals.weight?.toString() ?? '몸무게'}kg',
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    Row(
                      children: [
                        Text('BMI : ${globals.bmi?.toString() ?? 'bmi'}',
                            style: TextStyle(fontSize: 12)),
                        SizedBox(width: 5),
                      ],
                    ),
                    Text(
                      'BMR : ${globals.bmr?.truncate().toString() ?? 'bmr'}',
                      style: TextStyle(fontSize: 12),
                    ),

                    */
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            //임시
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text('목록 보기', style: TextStyle(fontSize: 16)),
                Divider(),
                ListTile(
                  title: Text('의약품 복용 일정', style: TextStyle(fontSize: fontSize)),
                  onTap: () {
                    Navigator.pushNamed(context, '/DosageSchedule');
                  },
                ),
                ListTile(
                  title: Text('식단 관리' , style: TextStyle(fontSize: fontSize)),
                  onTap: () {
                    Navigator.pushNamed(context, '/DietSchedule');
                  },
                ),
                ListTile(
                  title: Text('나만의 처방전', style: TextStyle(fontSize: fontSize)),
                  onTap: () {
                    Navigator.pushNamed(context, '/Prescription');
                  },
                ),
                ListTile(
                  title: Text('일정 관리', style: TextStyle(fontSize: fontSize)),
                  onTap: () {
                    Navigator.pushNamed(context, '/schedule');
                  },
                ),
                ListTile(
                  title: Text('습관 만들기', style: TextStyle(fontSize: fontSize)),
                  onTap: () {
                    Navigator.pushNamed(context, '/routine');
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
