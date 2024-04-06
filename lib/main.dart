import 'package:doctor_nyang/screen/screen_home.dart';
import 'package:doctor_nyang/screen/screen_intro.dart';
import 'package:doctor_nyang/screen/screen_login.dart';
import 'package:doctor_nyang/screen/screen_register.dart';
import 'package:doctor_nyang/screen/screen_user.dart';
import 'package:flutter/material.dart';
// flutter_tts 사용을 위한 라이브러리 임포트
import 'package:flutter_tts/flutter_tts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  get chatRoomId => null;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      home: Login(),//MyHomePage(key: UniqueKey(),),//Login(),//MyHomePage(key: UniqueKey(),),
      routes: {
        '/login': (context) => Login(),
        '/register': (context) => Register(),
        '/home': (context) => HomeScreen(),
        '/MyHomePage': (context) => MyHomePage(key: UniqueKey()),
      },
    );
  }
}
class MyHomePage extends StatefulWidget {
  MyHomePage({required Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FlutterTts tts = FlutterTts();
  final TextEditingController con = TextEditingController();
  int _currentIndex = 0;


  @override
  void initState() {
    super.initState();

    // setLanguage: 언어 설정 / setSpeechRate(): 읽기 속도 설정(0.0~1.0) & 0.0이 제일 느림 
    tts.setLanguage("ko-KR");
    tts.setSpeechRate(0);
    // tts.speak(""); -> tts.speak()으로 말할 내용
  }

  final List<Widget> _children = [
    HomeScreen(),
    HomeScreen(),
    UserScreen(),
  ];

  static get chatRoomId => null;

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;

    return Scaffold(
        body: _children[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: _currentIndex,
          items: [
            new BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'chat',
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'home',),
            new BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'mypage',
            ),

          ],
        ),
    );
  }
}
