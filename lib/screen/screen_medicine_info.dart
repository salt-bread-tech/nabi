import 'package:doctor_nyang/screen/screen_medicine_regist.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/globals.dart';
import '../services/urls.dart';

class MedicineInfo extends StatefulWidget {
  final String name;
  final String? fromRoute;

  MedicineInfo({required this.name, this.fromRoute});

  @override
  _MedicineInfoState createState() => _MedicineInfoState();
}

class _MedicineInfoState extends State<MedicineInfo> {
  Map<String, dynamic> medicineInfo = {};
  bool showMoreInfo = false;

  @override
  void initState() {
    super.initState();
    fetchMedicineInfo();
  }

  Future<void> fetchMedicineInfo() async {
    final type = '0';
    final response = await http.get(Uri.parse('$baseUrl/medicine/${widget.name}/$type'), headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final data = json.decode(utf8.decode(response.bodyBytes));

      setState(() {
        medicineInfo = {
          'itemName': data['itemName'] ?? '제품명 정보 없음',
          'efcyQesitm': data['efcyQesitm'] ?? '효능 정보 없음',
          'useMethodQesitm': data['useMethodQesitm'] ?? '사용법 정보 없음',
          'atpnWarnQesitm': data['atpnWarnQesitm'] ?? '주의사항 경고 정보 없음',
          'atpnQesitm': data['atpnQesitm'] ?? '약의 사용상 주의사항 정보 없음',
          'intrcQesitm': data['intrcQesitm'] ?? '상호작용 정보 없음',
          'seQesitm': data['seQesitm'] ?? '부작용 정보 없음',
          'depositMethodQesitm': data['depositMethodQesitm'] ?? '보관법 정보 없음',
        };
      });
    } else {
      throw Exception('Failed to load medicine info');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.name,
          style: TextStyle(fontSize: 16),
        ),
      ),
      body: medicineInfo.isNotEmpty
          ? SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoTextWidget(MedicineName: '제품명', content: medicineInfo['itemName']),
              InfoTextWidget(MedicineName: '효능', content: medicineInfo['efcyQesitm']),
              InfoTextWidget(MedicineName: '사용법', content: medicineInfo['useMethodQesitm']),
              if (showMoreInfo) ...[
                InfoTextWidget(MedicineName: '약의 사용상 주의사항', content: medicineInfo['atpnQesitm']),
                InfoTextWidget(MedicineName: '상호작용', content: medicineInfo['intrcQesitm']),
                InfoTextWidget(MedicineName: '부작용', content: medicineInfo['seQesitm']),
                InfoTextWidget(MedicineName: '보관법', content: medicineInfo['depositMethodQesitm']),
              ],
              TextButton(
                onPressed: () {
                  setState(() {
                    showMoreInfo = !showMoreInfo;
                  });
                },
                child: Text(
                  showMoreInfo ? '닫기' : '추가 정보 더 보기',
                  style: TextStyle(color: Color(0xFF969696)),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      )
          : Center(child: CircularProgressIndicator()),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Color(0xFFDCF4FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              if (widget.fromRoute == 'prescription') {
                Navigator.pop(context);
                Navigator.pop(context);
                searchText = widget.name;
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicineRegist(name: widget.name),
                  ),
                );
              }
            },
            child: Text(
              '등록하기',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}

class InfoTextWidget extends StatelessWidget {
  final String MedicineName;
  final String? content;

  const InfoTextWidget({
    Key? key,
    required this.MedicineName,
    this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dosageInfoText = (content == null || content!.isEmpty) ? '정보 없음' : content;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(MedicineName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF969696))),
        Text(dosageInfoText!, style: TextStyle(fontSize: 14)),
        SizedBox(height: 10),
      ],
    );
  }
}
