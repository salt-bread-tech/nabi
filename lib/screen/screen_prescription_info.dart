import 'dart:collection';

import 'package:doctor_nyang/assets/theme.dart';
import 'package:doctor_nyang/screen/screen_medicine_info.dart';
import 'package:doctor_nyang/screen/screen_medicine_search.dart';
import 'package:doctor_nyang/services/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/urls.dart';
import '../widgets/widget_addPrescription.dart';
import '../widgets/widget_delete.dart';

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
  final String? fromRoute;

  PrescriptionInfoScreen({
    required this.id,
    this.fromRoute,
  });

  @override
  _PrescriptionInfoScreenState createState() => _PrescriptionInfoScreenState();
}

class _PrescriptionInfoScreenState extends State<PrescriptionInfoScreen> {
  late DateTime selectedMonth;
  Map<String, dynamic> prescription = {};
  List<dynamic> medicineTakings = [];
  Map<String, dynamic> medicineTaking = {};
  List<String> time = ['아침', '점심', '저녁', '취침전'];
  List<String> medicineTakingTimes = ['식전', '식중', '식후', '상관 없음'];
  List<String> selectedTime = [];
  int selectedMedicineTakingTimes = 0;
  List<Color> registeredDosingScheduleColor = [
    AppTheme.pastelPink.withOpacity(0.5),
    AppTheme.pastelBlue.withOpacity(0.5),
  ];
  List<String> registeredDosingScheduleText = ['복용 일정 추가', '복용 일정 삭제'];
  String medicineName = '';
  TextEditingController medicineNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    selectedMonth = DateTime.now().toUtc();
    getPrescription(widget.id);
  }

  @override
  void dispose() {
    medicineNameController.dispose();
    super.dispose();
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

        print(prescription);

        print('처방전 조회 성공');
      } else {
        print('처방전 조회 실패');
      }
    } catch (e) {
      print('네트워크 오류 $e');
    }
  }

  Future<void> addMedicine(
      {required int prescriptionId,
      required String medicineName,
      required String once,
      required int days,
      required List<int> time,
      required int dosage}) async {
    final String url = '$baseUrl/medicine';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'prescriptionId': prescriptionId,
          'medicineName': medicineName,
          'once': once,
          'days': days,
          'time': time,
          'dosage': dosage,
        }),
      );

      if (response.statusCode == 200) {
        print('처방전 추가 성공');
        getPrescription(widget.id);
      } else {
        print('처방전 추가 실패');
      }
    } catch (e) {
      print('네트워크 오류 $e');
    }
  }

  Future<void> editMedicine(
      {required int medicineId,
      required String medicineName,
      required String once,
      required int days,
      required List<int> time,
      required int dosage}) async {
    final String url = '$baseUrl/medicine';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'medicineId': medicineId,
          'medicineName': medicineName,
          'once': once,
          'days': days,
          'time': time,
          'dosage': dosage,
        }),
      );

      if (response.statusCode == 200) {
        print('처방전 수정 성공');
        getPrescription(widget.id);
      } else {
        print('처방전 수정 실패');
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

  Future<void> addDosage(int medicineId) async {
    final String url = '$baseUrl/dosage';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'medicineId': medicineId,
        }),
      );

      if (response.statusCode == 200) {
        print('복용일정 추가 성공');
      } else {
        print('복용일정 추가 실패');
      }
    } catch (e) {
      print('네트워크 오류 $e');
    }
  }

  Future<void> deleteDosage(int medicineId) async {
    final String url = '$baseUrl/dosage/medicine/$medicineId';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('복용일정 삭제 성공');
      } else {
        print('복용일정 삭제 실패');
      }
    } catch (e) {
      print('네트워크 오류 $e');
    }
  }

  void showAddMedicineModal(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize14 = screenWidth * 0.035;

    medicineNameController.clear();
    selectedTime = [];
    selectedMedicineTakingTimes = 0;

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                  height: 370,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: screenWidth * 0.7,
                            child: TextField(
                              controller: medicineNameController,
                              decoration: InputDecoration(
                                hintText: '약 이름',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MedicineSearch(
                                        fromRoute: widget.fromRoute),
                                  ),
                                );
                                setState(() {
                                  medicineName = searchText!;
                                  medicineNameController..text = medicineName;
                                });
                              },
                              icon: Icon(Icons.search)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text('복용 시간'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: time
                            .map((e) => ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (selectedTime.contains(e)) {
                                        selectedTime.remove(e);
                                      } else {
                                        selectedTime.add(e);
                                      }
                                    });
                                  },
                                  child: Text(e,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: fontSize14)),
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: selectedTime.contains(e)
                                        ? AppTheme.pastelBlue
                                        : Colors.grey[200],
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                ))
                            .toList(),
                      ),
                      SizedBox(height: 10),
                      Text('복용 방법'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: medicineTakingTimes
                            .map((e) => ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedMedicineTakingTimes =
                                          medicineTakingTimes.indexOf(e);
                                    });
                                  },
                                  child: Text(e,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: fontSize14)),
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor:
                                        medicineTakingTimes.indexOf(e) ==
                                                selectedMedicineTakingTimes
                                            ? AppTheme.pastelBlue
                                            : Colors.grey[200],
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                ))
                            .toList(),
                      ),
                      SizedBox(height: 10),
                      Text('복용량'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('총'),
                          Container(
                            width: 50,
                            child: TextField(
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              decoration: InputDecoration(
                                hintText: '1',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  medicineTaking['days'] = int.parse(value);
                                });
                              },
                            ),
                          ),
                          Text('일'),
                          Text('하루'),
                          Container(
                            alignment: Alignment.center,
                            width: 50,
                            child: Text('${selectedTime.length}'),
                          ),
                          Text('번'),
                          Container(
                            width: 50,
                            child: TextField(
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              decoration: InputDecoration(
                                hintText: '1',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                alignLabelWithHint: true,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  medicineTaking['once'] = value;
                                });
                              },
                            ),
                          ),
                          Text('정(포)'),
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        height: 55,
                        child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Color(0xFFEBEBEB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              addMedicine(
                                prescriptionId: widget.id,
                                medicineName: medicineNameController.text,
                                once: medicineTaking['once'].toString(),
                                days: medicineTaking['days'],
                                time: selectedTime
                                    .map((e) => time.indexOf(e))
                                    .toList(),
                                dosage: selectedMedicineTakingTimes,
                              );
                              Navigator.pop(context);
                            },
                            child: Text('등록하기',
                                style: TextStyle(color: Colors.black))),
                      ),
                    ],
                  )));
        });
      },
    );
  }

  void showEditMedicineModal(BuildContext context, int index) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize14 = screenWidth * 0.035;
    var medicineTaking = prescription['medicineTakings'][index];
    selectedTime = medicineTaking['time']
        .map((e) => time[e])
        .toList()
        .cast<String>()
        .toList();
    selectedMedicineTakingTimes =
        medicineTakingTimes.indexOf(medicineTaking['dosage']);
    medicineNameController.text = medicineTaking['medicineName'];
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                  height: 370,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: screenWidth * 0.7,
                            child: TextField(
                              controller: medicineNameController,
                              decoration: InputDecoration(
                                hintText: '약 이름',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          IconButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MedicineSearch(
                                        fromRoute: widget.fromRoute),
                                  ),
                                );
                                setState(() {
                                  medicineName = searchText!;
                                  medicineNameController..text = medicineName;
                                });
                              },
                              icon: Icon(Icons.search)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text('복용 시간'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: time
                            .map((e) => ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      if (selectedTime.contains(e)) {
                                        selectedTime.remove(e);
                                      } else {
                                        selectedTime.add(e);
                                      }
                                    });
                                  },
                                  child: Text(e,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: fontSize14)),
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: selectedTime.contains(e)
                                        ? AppTheme.pastelBlue
                                        : Colors.grey[200],
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                ))
                            .toList(),
                      ),
                      SizedBox(height: 10),
                      Text('복용 방법'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: medicineTakingTimes
                            .map((e) => ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedMedicineTakingTimes =
                                          medicineTakingTimes.indexOf(e);
                                    });
                                  },
                                  child: Text(e,
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: fontSize14)),
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor:
                                        medicineTakingTimes.indexOf(e) ==
                                                selectedMedicineTakingTimes
                                            ? AppTheme.pastelBlue
                                            : Colors.grey[200],
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                ))
                            .toList(),
                      ),
                      SizedBox(height: 10),
                      Text('복용량'),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('총'),
                          Container(
                            width: 50,
                            child: TextField(
                              controller: TextEditingController()
                                ..text = medicineTaking['days'].toString(),
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              decoration: InputDecoration(
                                hintText: '1',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  medicineTaking['days'] = int.parse(value);
                                });
                              },
                            ),
                          ),
                          Text('일'),
                          Text('하루'),
                          Container(
                            alignment: Alignment.center,
                            width: 50,
                            child: Text('${selectedTime.length}'),
                          ),
                          Text('번'),
                          Container(
                            width: 50,
                            child: TextField(
                              controller: TextEditingController()
                                ..text = medicineTaking['once'].toString(),
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              decoration: InputDecoration(
                                hintText: '1',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                alignLabelWithHint: true,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  medicineTaking['once'] = value;
                                });
                              },
                            ),
                          ),
                          Text('정(포)'),
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        height: 55,
                        child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Color(0xFFEBEBEB),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              editMedicine(
                                medicineId: medicineTaking['medicineId'],
                                medicineName: medicineNameController.text,
                                once: medicineTaking['once'].toString(),
                                days: medicineTaking['days'],
                                time: selectedTime
                                    .map((e) => time.indexOf(e))
                                    .toList(),
                                dosage: selectedMedicineTakingTimes,
                              );
                              Navigator.pop(context);
                            },
                            child: Text('수정하기',
                                style: TextStyle(color: Colors.black))),
                      ),
                    ],
                  )));
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize16 = screenWidth * 0.04;
    double fontSize13 = screenWidth * 0.0325;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '${prescription['prescriptionName']}',
          style: TextStyle(color: Colors.black, fontSize: fontSize16),
          textAlign: TextAlign.center,
        ),
        iconTheme: IconThemeData(color: Colors.black),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              showAddMedicineModal(context);
            },
          ),
        ],
      ),
      body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: prescription['medicineTakings'] == null ||
                  prescription['medicineTakings'].isEmpty
              ? Center(
                  child: Text('처방전 내용이 없습니다.${'\n'}+ 버튼을 눌러 추가해주세요.',
                      textAlign: TextAlign.center))
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
                    Column(
                      children: List.generate(
                          prescription['medicineTakings'].length, (index) {
                        var medicineTaking =
                            prescription['medicineTakings'][index];
                        return Container(
                            margin: EdgeInsets.only(bottom: 20),
                            child: Slidable(
                              endActionPane: ActionPane(
                                motion: const DrawerMotion(),
                                children: [
                                  SlidableAction(
                                    flex: 1,
                                    onPressed: (context) => {
                                      showEditMedicineModal(context, index),
                                    },
                                    backgroundColor: Colors.black12,
                                    foregroundColor: Colors.white,
                                    icon: Iconsax.edit,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(30)),
                                  ),
                                  SlidableAction(
                                    flex: 1,
                                    onPressed: (context) => {
                                      deleteMedicine(
                                          medicineTaking['medicineId']),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                              ? registeredDosingScheduleColor[1]
                                              : registeredDosingScheduleColor[
                                                  0],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${medicineTaking['medicineName']}',
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: fontSize13,
                                              ),
                                            ),
                                            Text(
                                              '${medicineTaking['time'].map((e) => time[e]).toList().join(' ')}',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: fontSize13,
                                              ),
                                            ),
                                            Text(
                                                '${medicineTaking['days']}일 동안 하루에 ${medicineTaking['time'].length}번 ${medicineTaking['once']}정(포) ',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: fontSize13,
                                                )),
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
                                                  onTap: () {
                                                    print(medicineTaking[
                                                        'registeredDosingSchedule']);
                                                    if (medicineTaking[
                                                        'registeredDosingSchedule']) {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return DeleteConfirmDialog(
                                                            title: '복용 일정 삭제',
                                                            content:
                                                                '이 복용 일정을 삭제하시겠습니까?',
                                                            onConfirm: () {
                                                              deleteDosage(
                                                                  medicineTaking[
                                                                      'medicineId']);
                                                              setState(() {
                                                                medicineTaking[
                                                                        'registeredDosingSchedule'] =
                                                                    false;
                                                              });
                                                            },
                                                          );
                                                        },
                                                      );
                                                    } else {
                                                      addDosage(medicineTaking[
                                                          'medicineId']);
                                                      setState(() {
                                                        medicineTaking[
                                                                'registeredDosingSchedule'] =
                                                            true;
                                                      });
                                                    }
                                                  },
                                                  child: Text(
                                                      '${medicineTaking['registeredDosingSchedule'] ? registeredDosingScheduleText[1] : registeredDosingScheduleText[0]}',
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: fontSize13,
                                                      ))),
                                              Text(
                                                ' ',
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: fontSize13,
                                                ),
                                              ),
                                              Text(
                                                '${medicineTaking['dosage'] == '상관 없음' ? ' ' : '${medicineTaking['dosage']}'}',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: fontSize13,
                                                ),
                                              )
                                            ])),
                                  ],
                                ),
                              ),
                            ));
                      }),
                    ),
                  ],
                )),
    );
  }
}
