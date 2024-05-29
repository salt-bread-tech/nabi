import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../main.dart';

class IntroForSetting extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroForSetting> {
  int activeIndex = 0;
  final List<String> images = ['images/intro_chat.png', 'images/intro_widget.png'];
  final List<String> texts = ['나비와 행복한 시간 보내기', '건강한 일상생활 만들기'];
  final List<String> texts2 = ['귀여운 고양이 나비와 일상적인 대화를 통해 \n 심리 상태를 공유하고 상담 가능해요', '일정, 식단, 의약품 복용 일정 관리 \n 습관 만들기, 나만의 처방전 만들기 등 \n 다양한 기능을 통해  건강한 일상생활 만들기'];

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: <Widget>[
            SizedBox(height: 90),
            Text(texts[activeIndex],textAlign: TextAlign.center,style: TextStyle(color: Colors.black,fontSize: 23,fontWeight: FontWeight.bold),),
            SizedBox(height: 20),
            Text(texts2[activeIndex],textAlign: TextAlign.center,style: TextStyle(color: Colors.black,fontSize: 13),),
            SizedBox(height: 20),
            Expanded(
              child: introslider(images, screenHeight),
            ),
            indicator(images),
            startButton(),
          ],
        ),
      ),
    );
  }

  Widget startButton() => Container(
    margin: EdgeInsets.symmetric(horizontal: 30),
    child: SizedBox(
      width: double.infinity,
      height: 40,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Color(0xFFD3EAFF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () async {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
            ModalRoute.withName('/Settings'),
          );
        },
        child: Text(
          '메인으로 돌아가기',
          style: TextStyle(color: Colors.black),
        ),
      ),
    ),
  );



  Widget introslider(List<String> images, double height) => CarouselSlider(
    options: CarouselOptions(
      height: height,
      autoPlay: false,
      viewportFraction: 0.8,
      enlargeCenterPage: true,
      initialPage: 0,
      onPageChanged: (index, reason) {
        setState(() {
          activeIndex = index;
        });
      },
    ),
    items: images
        .map((item) => Container(
      child: Center(
        child: Image.asset(item, fit: BoxFit.cover, width: 1000),
      ),
    ))
        .toList(),
  );

  Widget indicator(List<String> images) => Container(
    margin: const EdgeInsets.only(bottom: 20.0),
    child: AnimatedSmoothIndicator(
      activeIndex: activeIndex,
      count: images.length,
      effect: JumpingDotEffect(
        dotHeight: 6,
        dotWidth: 6,
        activeDotColor: Colors.black.withOpacity(0.5),
        dotColor: Color(0xFFD9D9D9).withOpacity(0.6),
      ),
    ),
  );
}
