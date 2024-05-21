import 'dart:ui';

import 'package:doctor_nyang/screen/screen_chat.dart';
import 'package:doctor_nyang/screen/screen_diet_schedule.dart';
import 'package:doctor_nyang/screen/screen_dosage_schedule.dart';
import 'package:doctor_nyang/screen/screen_home.dart';
import 'package:doctor_nyang/screen/screen_intro.dart';
import 'package:doctor_nyang/screen/screen_login.dart';
import 'package:doctor_nyang/screen/screen_medicine_regist.dart';
import 'package:doctor_nyang/screen/screen_medicine_search.dart';
import 'package:doctor_nyang/screen/screen_register.dart';
import 'package:doctor_nyang/screen/screen_routine.dart';
import 'package:doctor_nyang/screen/screen_settings.dart';
import 'package:doctor_nyang/screen/screen_user.dart';
import 'package:doctor_nyang/screen/screen_food_search.dart';
import 'package:doctor_nyang/screen/screen_webtoon.dart';
import 'package:doctor_nyang/screen/screen_schedule_calendar.dart';
import 'package:doctor_nyang/widgets/widget_OCR_modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  await initializeDateFormatting();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(backgroundColor: Colors.white, scrolledUnderElevation: 0),
        cardColor: Colors.white,
        cupertinoOverrideTheme: CupertinoThemeData(barBackgroundColor: Colors.white),
        dialogBackgroundColor: Colors.white,
        brightness: Brightness.light,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        splashColor: Colors.transparent, // 잉크 투명하게
        highlightColor: Colors.transparent, // 하이라이트 투명하게
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('ko', 'KR'),
      ],

      home: IntroPage(),//Login()
      routes: {
        '/login': (context) => Login(),
        '/register': (context) => Register(),
        '/intro':(context) => IntroPage(),
        '/home': (context) => HomeScreen(),
        '/MyHomePage': (context) => MyHomePage(),
        '/chat': (context) => ChatScreen(),
        '/DosageSchedule': (context) => DosageSchedule(),
        '/MedicineSearch': (context) => MedicineSearch(),
        '/MedicineRegister': (context) => MedicineRegist(),
        '/DietSchedule': (context) => DietSchedule(),
        '/FoodSearch' : (context) => FoodSearch(),
        '/routine' : (context) => RoutineScreen(),
        '/webtoon' : (context) => WebtoonPage(),
        '/schedule' : (context) => ScheduleCalendar(),
        '/Setting': (context) => SettingsScreen(),
      },
    );
  }
}
class MyHomePage extends StatefulWidget {

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
    Color activeColor = Color(0xFF6696DE); // 활성화된 탭의 색상
    Color inactiveColor = Colors.grey; // 비활성화된 탭의 색상

    return Scaffold(
      body: Container(
        color: Colors.white,
      child: SafeArea(
        child: _children[_currentIndex],
      ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        onTap: onTabTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.message_favorite,
                color: _currentIndex == 0 ? activeColor : inactiveColor),
            activeIcon: Icon(Iconsax.message_favorite, color: activeColor),
            label: 'chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home_2,
                color: _currentIndex == 1 ? activeColor : inactiveColor),
            activeIcon: Icon(Iconsax.home_2, color: activeColor),
            label: 'home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.user,
                color: _currentIndex == 2 ? activeColor : inactiveColor),
            activeIcon: Icon(Iconsax.user, color: activeColor),
            label: 'mypage',
          ),
        ],
      ),
    );
  }
}