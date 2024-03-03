import 'package:flutter/material.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:doctor_nyang/widgets/widget_scheduel.dart';

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

    // return SafeArea(
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        //title: Text('Doctor Nyang'),
        toolbarHeight: 10,
        backgroundColor: Colors.white,
        leading: Container(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 15),
                    child: Text(
                      '$user님 안녕하세요',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      size: 24,
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/user');
                    },
                  )
                ],
              ),
              SizedBox(height: 30),
              Container(
                child: InkWell(
                  onTap: () {
                    print('채팅방으로 이동');
                  },
                  child: Image.asset("이미지 나중에 가져와서 넣기"),
                ),
              ),
              SizedBox(height: 30),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 15),
                // child: Text(
                //   '할 일',
                //   style: const TextStyle(
                //       fontSize: 18, fontWeight: FontWeight.w700),
                // ),
              ),
              EasyDateTimeLine(
                locale: "ko",
                initialDate: DateTime.now(),
                onDateChange: (selectedDate) {
                  //`selectedDate` the new date selected.
                },
                activeColor: const Color(0xffFFD6D6),
                headerProps: const EasyHeaderProps(
                  monthPickerType: MonthPickerType.switcher,
                  dateFormatter: DateFormatter.monthOnly(),
                ),
                dayProps: const EasyDayProps(
                  height: 56.0,
                  width: 56.0,
                  dayStructure: DayStructure.dayNumDayStr,
                  inactiveDayStyle: DayStyle(
                    borderRadius: 48.0,
                    dayNumStyle: TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                  activeDayStyle: DayStyle(
                    dayNumStyle: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 45,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  padding: EdgeInsets.symmetric(vertical: 7, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFEBEB),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: const Column(
                    children: [
                      ScheduleWidget(
                        startTime: 12,
                        content: '난정 만나러 가기',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return Scaffold();
  }
}
