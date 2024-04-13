import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/urls.dart';
import '../services/globals.dart' as globals;

class Food {
  final String name;
  final double servingSize;
  final double carbohydrate;
  final double protein;
  final double fat;
  final double calories;

  Food({
    required this.name,
    required this.servingSize,
    required this.carbohydrate,
    required this.protein,
    required this.fat,
    required this.calories,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      name: json['name'],
      servingSize: json['servingSize'],
      carbohydrate: json['carbohydrate'],
      protein: json['protein'],
      fat: json['fat'],
      calories: json['calories'],
    );
  }
}

class FoodSearch extends StatefulWidget {
  @override
  _FoodSearchState createState() => _FoodSearchState();
}

class _FoodSearchState extends State<FoodSearch> {
  List<dynamic> searchResults = [];
  Map<int, Food> foodsInfo = {};

  Future<void> searchFood(String food) async {
    final response = await http.get(Uri.parse('$baseUrl/foods/$food'));
    final decodedResponse = utf8.decode(response.bodyBytes);

    if (response.statusCode == 200) {
      final data = json.decode(decodedResponse) as List;

      List<String> processedData = data.map<String>((item) {
        String itemStr = item as String;
        List<String> parts = itemStr.split(',');

        return parts.first.trim();
      }).toList();

      setState(() {
        searchResults = processedData;
        foodsInfo = {};
      });

      loadFoodData();
    } else {
      throw Exception('Failed to load foods');
    }
  }

  FutureOr<Food?> fetchFood(String name, int index) async {
    final String url = '$baseUrl/food/$name/$index';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        String responseBody = utf8.decode(response.bodyBytes);
        Map<String, dynamic> food = json.decode(responseBody);

        print(food);

        setState(() {
          foodsInfo[index] = Food.fromJson(food);
        });
      } else {
        throw Exception('Failed to load food');
      }
    } catch (e) {
      print('error: $e');
    }
  }

  Future<void> loadFoodData() async {
    for (int i = 0; i < searchResults.length; i++) {
      await fetchFood(searchResults[i], i);
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
                    searchFood(text);
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {},
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
            Food? food = foodsInfo[index];
            if (food == null) {
              return SizedBox();
            } else {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  title: Row(children: [
                    Text(
                        food.name.length > 14
                            ? food.name.substring(0, 14) + 'ⵈ'
                            : food.name,
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold)),
                    SizedBox(width: 5),
                    Text('${food?.servingSize.toStringAsFixed(0)}g',
                        style: TextStyle(fontSize: 10)),
                  ]),
                  subtitle: Text(
                      '탄수화물 ${food?.carbohydrate.toStringAsFixed(0)}g 단백질 ${food?.protein.toStringAsFixed(0)}g 지방 ${food?.fat.toStringAsFixed(0)}g',
                      style: TextStyle(fontSize: 11)),
                  trailing: Text('${food?.calories.toStringAsFixed(0)}kcal',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
