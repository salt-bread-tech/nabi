import 'package:doctor_nyang/assets/theme.dart';
import 'package:doctor_nyang/services/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/urls.dart';
import '../widgets/widget_addPrescription.dart';

class Prescription {
  final String prescriptionName;
  final String prescriptionDate;
  final List<MedicineTaking> medicineTakings;

  Prescription({
    required this.prescriptionName,
    required this.prescriptionDate,
    required this.medicineTakings,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    var list = json['medicineTakings'] as List;
    List<MedicineTaking> medicineTakingsList =
        list.map((i) => MedicineTaking.fromJson(i)).toList();

    return Prescription(
      prescriptionName: json['prescriptionName'],
      prescriptionDate: json['prescriptionDate'],
      medicineTakings: medicineTakingsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prescriptionName': prescriptionName,
      'prescriptionDate': prescriptionDate,
      'medicineTakings': medicineTakings.map((e) => e.toJson()).toList(),
    };
  }
}

class MedicineTaking {
  final int medicineId;
  final String medicineName;
  final int once;
  final int days;
  final List<int> time;
  final String dosage;
  final bool registeredDosingSchedule;

  MedicineTaking({
    required this.medicineId,
    required this.medicineName,
    required this.once,
    required this.days,
    required this.time,
    required this.dosage,
    required this.registeredDosingSchedule,
  });

  factory MedicineTaking.fromJson(Map<String, dynamic> json) {
    return MedicineTaking(
      medicineId: json['medicineId'],
      medicineName: json['medicineName'],
      once: json['once'],
      days: json['days'],
      time: List<int>.from(json['time']),
      dosage: json['dosage'],
      registeredDosingSchedule: json['registeredDosingSchedule'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicineId': medicineId,
      'medicineName': medicineName,
      'once': once,
      'days': days,
      'time': time,
      'dosage': dosage,
      'registeredDosingSchedule': registeredDosingSchedule,
    };
  }
}

class PrescriptionInfoScreen extends StatefulWidget {
  final int id;

  PrescriptionInfoScreen({
    required this.id,
  });

  @override
  _PrescriptionInfoScreenState createState() => _PrescriptionInfoScreenState();
}

class _PrescriptionInfoScreenState extends State<PrescriptionInfoScreen> {
  late DateTime selectedMonth;
  Map<String, dynamic> prescription = {};
  List<dynamic> medicineTakings = [];
  Map<String, dynamic> medicineTaking = {};
  List<String> time = ['아침', '점심', '저녁', '취침 전'];
  List<String> selectedTime = [];
  List<Color> registeredDosingScheduleColor = [
    AppTheme.pastelBlue.withOpacity(0.5),
    AppTheme.pastelPink.withOpacity(0.5),
  ];
  List<String> registeredDosingScheduleText = ['일정 추가 하기', '일정 추가 완료'];

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime.now();
    getPrescription(widget.id);
  }

  Future<void> getPrescription(int id) async {
    final String url = '$baseUrl/prescriptions/$id';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        String responseBody = utf8.decode(response.bodyBytes);

        final Map<String, dynamic> _data = jsonDecode(responseBody);
        final _prescription = Prescription.fromJson(_data);
        final _medicineTakings = _data['medicineTakings'] as List;
        _medicineTakings.forEach((element) {
          medicineTakings.add(MedicineTaking.fromJson(element));
        });

        setState(() {
          prescription = _prescription.toJson();
          medicineTakings = _medicineTakings;
        });

        medicineTakings.forEach((element) {
          setState(() {
            medicineTaking = element;
            selectedTime = time
                .where((element) =>
                    medicineTaking['time'].contains(time.indexOf(element)))
                .toList();
          });
        });

        print('처방전 조회 성공');
      } else {
        print('처방전 조회 실패');
      }
    } catch (e) {
      print('네트워크 오류 $e');
    }
  }

  Future<void> deleteMedicine(int id) async {
    final String url = '$baseUrl/medicine/$id';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('처방전 삭제 성공');
        getPrescription(widget.id);
      } else {
        print('처방전 삭제 실패');
      }
    } catch (e) {
      print('네트워크 오류 $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '${prescription['prescriptionName']}',
          style: TextStyle(color: Colors.black, fontSize: 17),
          textAlign: TextAlign.center,
        ),
        iconTheme: IconThemeData(color: Colors.black),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: prescription['medicineTakings'] == null ||
                  prescription['medicineTakings'].isEmpty
              ? Center(child: Text('처방전 내용이 없습니다.${'\n'}+ 버튼을 눌러 추가해주세요.', textAlign: TextAlign.center))
              : ListView(
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Spacer(),
                            Text(
                              '${prescription['prescriptionDate']}',
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ]),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: prescription['medicineTakings'].length,
                      itemBuilder: (context, index) {
                        final medicineTaking =
                            prescription['medicineTakings'][index];
                        return Slidable(
                          endActionPane: ActionPane(
                            motion: const DrawerMotion(),
                            children: [
                              SlidableAction(
                                flex: 1,
                                onPressed: (context) => {},
                                backgroundColor: Colors.black12,
                                foregroundColor: Colors.white,
                                icon: Iconsax.edit,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                              SlidableAction(
                                flex: 1,
                                onPressed: (context) => {
                                  deleteMedicine(medicineTaking['medicineId']),
                                  print(medicineTaking['medicineId'])
                                },
                                backgroundColor: Color(0xFFFF5050),
                                foregroundColor: Colors.white,
                                icon: Iconsax.trash,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                              ),
                            ],
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        bottomLeft: Radius.circular(30),
                                      ),
                                      color: medicineTaking[
                                              'registeredDosingSchedule']
                                          ? registeredDosingScheduleColor[0]
                                          : registeredDosingScheduleColor[1],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${medicineTaking['medicineName']}',
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          '${selectedTime.join(' ')}',
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Row(children: [
                                          Text(
                                              '${medicineTaking['days']}일 동안 하루에 ${medicineTaking['once']}번 ',
                                              style: TextStyle(
                                                color: Colors.grey,
                                              )),
                                          Text(
                                              '${medicineTaking['dosage'] == '상관없음' ? ' ' : '${medicineTaking['dosage']}'}',
                                              style: TextStyle(
                                                color: Colors.grey,
                                              )),
                                        ]),
                                      ],
                                    )),
                                Container(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 20, horizontal: 20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(30),
                                        bottomRight: Radius.circular(30),
                                      ),
                                      color: Colors.white,
                                    ),
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          GestureDetector(
                                              onTap: () {},
                                              child: Text(
                                                  '${medicineTaking['registeredDosingSchedule'] ? registeredDosingScheduleText[0] : registeredDosingScheduleText[1]}',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                  ))),
                                          Text(
                                            ' ',
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          Text(
                                            '${medicineTaking['dosage']}',
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          )
                                        ])),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                )),
    );
  }
}
