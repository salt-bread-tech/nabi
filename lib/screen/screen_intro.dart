import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  int activeIndex = 0;
  final List<String> images = ['images/1.png', 'images/2.png', 'images/3.png'];

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: <Widget>[
            Text('닥터냥 시작하기',textAlign: TextAlign.center,style: TextStyle(color: Colors.black),),
            SizedBox(height: 20),
            Expanded(
              child: introslider(images, screenHeight),
            ),
            indicator(images),
            //SizedBox(height: 20),
            startButton(),
            SizedBox(height: 20),
            registerButton(),
          ],
        ),
      ),
    );
  }

  Widget startButton() => Container(
    margin: EdgeInsets.all(20),
    child: SizedBox(
      width: double.infinity,
      height: 40,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Color(0xFFACD7FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () async {
          Navigator.pushNamed(context, '/register');
        },
        child: Text(
          '닥터냥 시작하기',
          style: TextStyle(color: Colors.black),
        ),
      ),
    ),
  );


  Widget registerButton() => TextButton(
    onPressed: () {
      Navigator.pushNamed(context, '/login');
    },
    child: RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.black,
        ),
        children: <TextSpan>[
          TextSpan(text: '계정이 있으신가요? ',style: TextStyle(fontSize: 15)),
          TextSpan(
              text: '로그인',
              style: TextStyle(color: Color(0xFF2144FF),fontSize: 15)),
          TextSpan(text: '하기',style: TextStyle(fontSize: 15)),
        ],
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
