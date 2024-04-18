import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/urls.dart';
import '../assets/theme.dart';

class Food {
  final String name;
  final double servingSize;
  final double calories;
  final double carbohydrate;
  final double protein;
  final double fat;
  final double sugars;
  final double salt;
  final double cholesterol;
  final double saturatedFattyAcid;
  final double transFattyAcid;

  Food({
    required this.name,
    required this.servingSize,
    required this.calories,
    required this.carbohydrate,
    required this.protein,
    required this.fat,
    required this.sugars,
    required this.salt,
    required this.cholesterol,
    required this.saturatedFattyAcid,
    required this.transFattyAcid,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      name: json['name'],
      servingSize: json['servingSize'],
      carbohydrate: json['carbohydrate'],
      protein: json['protein'],
      fat: json['fat'],
      calories: json['calories'],
      sugars: json['sugars'],
      salt: json['salt'],
      cholesterol: json['cholesterol'],
      saturatedFattyAcid: json['saturatedFattyAcid'],
      transFattyAcid: json['transFattyAcid'],
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

  final TextEditingController _controller = TextEditingController();
  final List<String> _meals = ['아침', '점심', '저녁', '간식'];
  String _selectedMeal = '';
  final List<String> _grams = ['인분', 'g'];
  String _selectedGram = '';
  double _selectedQuantity = 1.0;

  void _incrementQuantity() {
    setState(() {
      _selectedQuantity += 0.5;
      _controller.text = _selectedQuantity.toString();
    });
  }

  void _decrementQuantity() {
    if (_selectedQuantity > 0.5) {
      setState(() {
        _selectedQuantity -= 0.5;
        _controller.text = _selectedQuantity.toString();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _controller.text = _selectedQuantity.toString();
    setState(() {
      _selectedMeal = _meals[0];
      _selectedGram = _grams[0];
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void showCustomModalBottomSheet(BuildContext context, Food food) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState){
        return Container(
          height: 530,
          padding: const EdgeInsets.all(30.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    '${food.name}',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${food.servingSize.toStringAsFixed(0)}g',
                    style: TextStyle(fontSize: 12),
                  ),
                  Expanded(
                    child: Text(
                      '${food.calories.toStringAsFixed(0)} kcal',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                      alignment: Alignment.center,
                      width: 85,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Color(0xFFD9D9D9),
                          width: 1,
                        ),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                          child: DropdownButton(
                        value: _selectedMeal,
                        dropdownColor: Colors.white,
                        onChanged: (value) {
                          setState(() {
                            _selectedMeal = value!;
                          });
                        },
                        items: _meals
                            .map((e) =>
                                DropdownMenuItem(child: Text(e), value: e))
                            .toList(),
                        borderRadius: BorderRadius.circular(8),
                      ))),
                  SizedBox(width: 5),
                  Container(
                    alignment: Alignment.center,
                    width: 135,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Color(0xFFD9D9D9),
                        width: 1,
                      ),
                      color: Colors.white,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove,
                              size: 20, color: Color(0xFFD9D9D9)),
                          onPressed: _decrementQuantity,
                        ),
                        Container(
                          width: 35,
                          child: TextField(
                            controller: _controller,
                            textAlign: TextAlign.center,
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            decoration:
                                InputDecoration(border: InputBorder.none),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add,
                              size: 20, color: Color(0xFFD9D9D9)),
                          onPressed: _incrementQuantity,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 5),
                  Container(
                      alignment: Alignment.center,
                      width: 85,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Color(0xFFD9D9D9),
                          width: 1,
                        ),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                        value: _selectedGram,
                        dropdownColor: Colors.white,
                        onChanged: (newValue) {
                          setState(() {
                            _selectedGram = newValue!;
                          });
                        },
                        items: _grams
                            .map((e) =>
                                DropdownMenuItem(child: Text(e), value: e))
                            .toList(),
                        borderRadius: BorderRadius.circular(8),
                      ))),
                ],
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('탄수화물', style: TextStyle(fontSize: 16)),
                  Text('${food.carbohydrate.toStringAsFixed(0)}g',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(FontAwesomeIcons.caretRight,
                      size: 16, color: AppTheme.subTitleTextColor),
                  SizedBox(width: 5),
                  Text('당류',
                      style: TextStyle(
                          fontSize: 16, color: AppTheme.subTitleTextColor)),
                  Expanded(
                    child: Text('${food.sugars.toStringAsFixed(0)}g',
                        style: TextStyle(
                            fontSize: 16, color: AppTheme.subTitleTextColor),
                        textAlign: TextAlign.end),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('단백질', style: TextStyle(fontSize: 16)),
                  Text('${food.protein.toStringAsFixed(0)}g',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('지방', style: TextStyle(fontSize: 16)),
                  Text('${food.fat.toStringAsFixed(0)}g',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(FontAwesomeIcons.caretRight,
                      size: 16, color: AppTheme.subTitleTextColor),
                  SizedBox(width: 5),
                  Text('포화지방',
                      style: TextStyle(
                          fontSize: 16, color: AppTheme.subTitleTextColor)),
                  Expanded(
                    child: Text(
                        '${food.saturatedFattyAcid.toStringAsFixed(0)}g',
                        style: TextStyle(
                            fontSize: 16, color: AppTheme.subTitleTextColor),
                        textAlign: TextAlign.end),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(FontAwesomeIcons.caretRight,
                      size: 16, color: AppTheme.subTitleTextColor),
                  SizedBox(width: 5),
                  Text('트랜스지방',
                      style: TextStyle(
                          fontSize: 16, color: AppTheme.subTitleTextColor)),
                  Expanded(
                    child: Text('${food.transFattyAcid.toStringAsFixed(0)}g',
                        style: TextStyle(
                            fontSize: 16, color: AppTheme.subTitleTextColor),
                        textAlign: TextAlign.end),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('나트륨', style: TextStyle(fontSize: 16)),
                  Text('${food.salt.toStringAsFixed(0)}mg',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
              SizedBox(height: 24),
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
                    Navigator.pop(context);
                  },
                  child: Text(
                    '기록하기',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        );
      },

    );
  });
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
                color: AppTheme.pastelYellow,
                child: ListTile(
                  onTap: () {
                    _selectedQuantity = 1.0;
                    _selectedGram = '인분';
                    _selectedMeal = '아침';
                    setState(() {
                      _controller.text = _selectedQuantity.toString();
                    });
                    showCustomModalBottomSheet(context, food);
                  },
                  title: Row(children: [
                    Text(food.name,
                        overflow: TextOverflow.ellipsis,
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
