import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WebtoonPage extends StatefulWidget {
  @override
  _WebtoonPageState createState() => _WebtoonPageState();
}

class _WebtoonPageState extends State<WebtoonPage>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  bool _isClickable = false;
  late AnimationController _controller;
  late Animation<int> _typingAnimation;

  final List<String> images = [
    'images/webtoon1.jpeg',
    'images/webtoon1.jpeg',
    'images/webtoon2.jpeg',
    'images/webtoon2.jpeg',
    'images/webtoon3.jpeg',
    'images/webtoon3.jpeg',
    'images/webtoon4.jpeg',
    'images/webtoon4.jpeg'
  ];
  final List<String> texts = [
    '비가 세차게 내리는 어느 날… 당신은 동네 골목 길을 걷고 있었습니다.',
    '어? 저 앞에 작은 택배 박스가 보이네요. 당신은 홀린듯이 박스를 향해 걸었습니다.',
    '박스 안을 확인해보니… 작은 고양이가 들어 있었어요!',
    '고양이는 비에 젖은 채 추위에 떨고 있었습니다. ',
    '목에는 ‘나비’ 라고 쓰여 있는 목걸이를 하고 있었어요.',
    '박스에는 ‘데려가주세요.’ 라는 문구가 적혀있네요.',
    '누가 키우던 고양이였을까요?',
    '당신은 고양이… 나비를 집에 데려가기로 결심했습니다.'
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 2000),
      // A fixed time duration for all texts
      vsync: this,
    );
    _setupAnimation();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setupAnimation() {
    _controller.reset();
    _typingAnimation =
        IntTween(begin: 0, end: texts[currentIndex].length).animate(_controller)
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              setState(() {
                _isClickable = true;
              });
            }
          });
    _controller.forward();
  }

  void _onTap() {
    if (_isClickable) {
      if (currentIndex + 1 < texts.length) {
        setState(() {
          currentIndex++;
          _isClickable = false;
          _setupAnimation();
        });
      }
      if (currentIndex == 8) {
        Navigator.pushNamed(context, '/MyHomePage');
      }
    }
  }

  void _changeBackground() {
    setState(() {
      if (currentIndex < 8) {
        currentIndex = (currentIndex + 1) % images.length;
      }
    });
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(images[currentIndex]),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
              bottom: 70,
              child: GestureDetector(
                onTap: _onTap,
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: AnimatedBuilder(
                    animation: _typingAnimation,
                    builder: (context, child) {
                      return Container(
                          width: MediaQuery.of(context).size.width - 40,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.all(20),
                          child: Text(
                            texts[currentIndex]
                                .substring(0, _typingAnimation.value),
                            style: TextStyle(
                                fontSize: 20, fontFamily: 'omyu_pretty'),
                          ));
                    },
                  ),
                ),
              )),
        ]));
  }
}
