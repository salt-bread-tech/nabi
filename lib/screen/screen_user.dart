import 'package:doctor_nyang/screen/screen_settings.dart';
import 'package:flutter/material.dart';
import '../services/globals.dart' as globals;
import '../services/service_auth.dart';
import '../widgets/widget_imagePick_modal.dart';

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
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => SettingsScreen(),
              ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey,
                  //사진 추가??
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(globals.nickName ?? '이름', style: TextStyle(fontSize: 20)),
                    SizedBox(height: 5),
                    Text(globals.birth ?? '생년월일', style: TextStyle(fontSize: 12)),
                    Row(
                      children: [
                        Text('${globals.height?.toString() ?? '키'}cm', style: TextStyle(fontSize: 12)),
                        SizedBox(width: 5),
                        Text('${globals.weight?.toString() ?? '몸무게'}kg', style: TextStyle(fontSize: 12)),
                      ],
                    ),
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
                Text('기능 목록',style: TextStyle(fontSize: 16)),
                Divider(),
                ListTile(
                  title: Text('약 복용 루틴'),
                  onTap: () {
                    Navigator.pushNamed(context, '/DosageSchedule');
                  },
                ),
                ListTile(
                  title: Text('복용할 약 추가'),
                  onTap: () {
                    Navigator.pushNamed(context, '/MedicineSearch');
                  },
                ),
                ListTile(
                  title: Text('식단 관리'),
                  onTap: () {
                    Navigator.pushNamed(context, '/DietSchedule');
                  },
                ),ListTile(
                  title: Text('처방전 추가'),
                  onTap: () {
                    OCRModal.show(context);
                  },
                ),
                ListTile(
                  title: Text('routin'),
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
