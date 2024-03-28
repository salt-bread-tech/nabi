import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class MedicineRegist extends StatefulWidget {
  late final String name;

  MedicineRegist({required this.name});

  @override
  _MedicineRegistState createState() => _MedicineRegistState();
}

class _MedicineRegistState extends State<MedicineRegist> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('복용 일정 추가하기', style: TextStyle(fontSize: 16),),
      ),
      body: Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(

          )
      ),
    );
  }
}