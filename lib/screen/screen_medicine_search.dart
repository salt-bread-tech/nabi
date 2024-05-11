import 'package:doctor_nyang/screen/screen_medicine_info.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/globals.dart';
import '../services/urls.dart';

class MedicineSearch extends StatefulWidget {
  @override
  _MedicineSearchState createState() => _MedicineSearchState();
}

class _MedicineSearchState extends State<MedicineSearch> {
  List<dynamic> searchResults = [];
  String searchText = '';

  Future<void> searchMedicines(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/medicines/$query'),headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },);
    final decodedResponse = utf8.decode(response.bodyBytes);

    if (response.statusCode == 200) {
      final data = json.decode(decodedResponse) as List;

      List<String> processedData = data.map<String>((item) {
        String itemStr = item as String;
        List<String> parts = itemStr.split('(');
        return parts.first.trim();
      }).toList();

      setState(() {
        searchResults = processedData;
      });
    } else {
      throw Exception('Failed to load medicines');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10.0,
                spreadRadius: 0.1,
                offset: Offset(0, 1),
              ),
            ],
            color: Colors.white,
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: <Widget>[
              SizedBox(
                width: 50,
              ),
              Flexible(
                child: TextField(
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: '검색어 입력'),
                  onChanged: (text) {
                    searchText = text;
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () async{
                  searchMedicines(searchText);
                },
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: ListView.builder(
          itemCount: searchResults.length,
          itemBuilder: (context, index) {
            String itemName = searchResults[index];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MedicineInfo(name: itemName),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(itemName),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
