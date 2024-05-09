import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WebtoonPage extends StatefulWidget {
  @override
  _WebtoonPageState createState() => _WebtoonPageState();
}

class _WebtoonPageState extends State<WebtoonPage> {
  int activeIndex = 0;
  final List<String> images = ['images/webtoon1.jpeg', 'images/webtoon2.jpeg', 'images/webtoon3.jpeg','images/webtoon4.jpeg'];
  final List<String> texts = ['비가 세차게 내리는 어느 날… 당신은 동네 골목 길을 걷고 있었습니다.','박스 안을 확인해보니… 안에는 작은 고양이가 들어 있었어요!' ,'목에는 ‘나비’ 라는 목걸이가 걸려 있었어요.', '누가 키우던 고양이였을까요?'];
  final List<String> texts2 = ['어? 저 앞에 작은 택배 박스가 보이네요. 당신은 홀린듯이 박스를 향해 걸었습니다.', '그 고양이는 비에 젖은 채 추위에 떨고 있습니다. ', '박스에 붙어있는 쪽지에는 ‘데려가주세요.’ 라고 적혀있네요.','당신은 고양이… 나비를 집에 데려가기로 결심했습니다.'];

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: <Widget>[
            Expanded(
              child: introslider(images, screenHeight),
            ),
            indicator(images),
            Text(texts[activeIndex],textAlign: TextAlign.center,style: TextStyle(color: Colors.black,fontSize: 14),softWrap: true,),
            SizedBox(height: 10),
            Text(texts2[activeIndex],textAlign: TextAlign.center,style: TextStyle(color: Colors.black,fontSize: 13),),
            SizedBox(height: 30),

            //SizedBox(height: 20),
            startButton(),
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
          Navigator.pushNamed(context, '/MyHomePage');
        },
        child: Text(
          '시작하기',
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
