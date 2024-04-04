import 'package:flutter/material.dart';
import 'package:easy_date_timeline/easy_date_timeline.dart';
import 'package:doctor_nyang/widgets/widget_schedule.dart';
import '../services/service_schedule.dart';
import '../widgets/widget_diet.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  get user => '연재';
  int selectedTab = 0;
  int userUid = 1;
  DateTime selectedDate = DateTime.now();

  void _updateSelectedDate(DateTime newDate) {
    setState(() {
      selectedDate = newDate;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

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
                    padding: EdgeInsets.only(left: 5),
                    child: Text(
                      '$user님 안녕하세요',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      size: 21,
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
              ),
              SizedBox(
                child: EasyDateTimeLine(
                  locale: "ko",
                  initialDate: DateTime.now(),
                  onDateChange: (DateTime newDate) {
                    _updateSelectedDate(newDate);
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
              ),
              SizedBox(height: 20),
              Container(
                  height: 45,
                  width: 330,
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFEBEB),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: FutureBuilder<List<Schedule>>(
                    future: fetchSchedules(
                        userUid, DateTime.now().toString().substring(0, 10)),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('${snapshot.error}');
                      } else {
                        return ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            Schedule schedule = snapshot.data![index];
                            int schedules = snapshot.data!.length;
                            return SizedBox(
                              height: 45 + schedules*20,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 7, horizontal: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEB),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: ScheduleWidget(
                                  time: schedule.date.hour,
                                  minute: schedule.date.minute,
                                  content: schedule.text,
                                ),
                              ),
                            );
                          },
                        );
                      }
                    },
                  )),
              SizedBox(height: 20),
              WidgetDiet(
                userCalories: 2000,
                breakfastCalories: 400,
                lunchCalories: 500,
                dinnerCalories: 500,
                snackCalories: 500,
                totalCarb: 24,
                totalFat: 50,
                totalProtein: 20,
              )
            ],
          ),
        ),
      ),
    );
    return Scaffold();
  }
}
