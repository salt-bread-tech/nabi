import 'package:flutter/material.dart';


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  get user => '연재';
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double width = screenSize.width;
    double height = screenSize.height;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          //title: Text('Doctor Nyang'),
          backgroundColor: Colors.white,
          leading: Container(),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child:Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                SizedBox(height: 100),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '$user님 안녕하세요',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                    SizedBox(
                      width: 30,
                      height: 35,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/userRoom');
                        },
                        child: Text(
                          '>',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 100),
                Container(
                  child: InkWell(
                    onTap: () {
                      print('채팅방으로 이동');
                    },
                    child: Image.asset("이미지 나중에 가져와서 넣기"),
                  ),
                ),
                SizedBox(height: 30),

                GridView.builder(
                  shrinkWrap: true,
                  itemCount: 4,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: (width - 200) / 2 / 120,
                  ),
                  itemBuilder: (context, index) {
                    return Card(
                      color: Colors.blue[index * 100],
                      child: Center(
                        child: Text(
                          '$index',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return Scaffold();


  }
}
