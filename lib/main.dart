import 'package:doctor_nyang/screen/screen_chat.dart';
import 'package:doctor_nyang/screen/screen_diet_schedule.dart';
import 'package:doctor_nyang/screen/screen_dosage_schedule.dart';
import 'package:doctor_nyang/screen/screen_home.dart';
import 'package:doctor_nyang/screen/screen_intro.dart';
import 'package:doctor_nyang/screen/screen_login.dart';
import 'package:doctor_nyang/screen/screen_medicine_search.dart';
import 'package:doctor_nyang/screen/screen_register.dart';
import 'package:doctor_nyang/screen/screen_user.dart';
import 'package:doctor_nyang/screen/screen_food_search.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        splashColor: Colors.transparent, // 잉크 투명하게
        highlightColor: Colors.transparent, // 하이라이트 투명하게
      ),

      home: IntroPage(),//Login(),//MyHomePage(key: UniqueKey(),),
      routes: {
        '/login': (context) => Login(),
        '/register': (context) => Register(),
        '/home': (context) => HomeScreen(),
        '/MyHomePage': (context) => MyHomePage(key: UniqueKey()),
        '/chat': (context) => ChatScreen(),
        '/DosageSchedule': (context) => DosageSchedule(),
        '/MedicineSearch': (context) => MedicineSearch(),
        '/DietSchedule': (context) => DietSchedule(),
        '/FoodSearch' : (context) => FoodSearch(),
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
  final TextEditingController con = TextEditingController();
  int _currentIndex = 1;


  @override
  void initState() {
    super.initState();

  }

  final List<Widget> _children = [
    ChatScreen(),
    HomeScreen(),
    UserScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _children[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_rounded),
              label: 'chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home), label: 'home',),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'mypage',
            ),

          ],
        ),
    );
  }
}
