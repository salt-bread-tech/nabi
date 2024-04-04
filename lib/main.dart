import 'package:doctor_nyang/screen/screen_home.dart';
import 'package:doctor_nyang/screen/screen_login.dart';
import 'package:doctor_nyang/screen/screen_register.dart';
import 'package:flutter/material.dart';
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
      home: Login(),//MyHomePage(key: UniqueKey(),),
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

    tts.setLanguage("ko-KR");
    tts.setSpeechRate(0);
    tts.speak("뭐라고 써야할지 모르겠다 뭐라고 써야할지 모르겠다 뭐라고 써야할지 모르겠다 뭐라고 써야할지 모르겠다 뭐라고 써야할지 모르겠다 뭐라고 써야할지 모르겠다 뭐라고 써야할지 모르겠다 뭐라고 써야할지 모르겠다 뭐라고 써야할지 모르겠다 뭐라고 써야할지 모르겠다 뭐라고 써야할지 모르겠다 ");
  }

  final List<Widget> _children = [
    HomeScreen(),
    //SignUpScreen(),
    //ChatRoomListScreen(),
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
              label: 'Home',
            ),
            new BottomNavigationBarItem(
              icon: Icon(Icons.mic), label: '임시',),
            new BottomNavigationBarItem(
              icon: Icon(Icons.mail),
              label: 'Messages',
            ),

          ],
        ),
    );
  }
}
