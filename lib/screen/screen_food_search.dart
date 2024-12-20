import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../services/globals.dart';
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

void showCustomModalBottomSheet(BuildContext context, Food food) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return CustomModalBottomSheet(food: food);
    },
  );
}

class CustomModalBottomSheet extends StatefulWidget {
  final Food food;

  CustomModalBottomSheet({required this.food});

  @override
  _CustomModalBottomSheetState createState() => _CustomModalBottomSheetState();
}

class _CustomModalBottomSheetState extends State<CustomModalBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _meals = ['아침', '점심', '저녁', '간식'];
  String _selectedMeal = '';
  final List<String> _grams = ['인분', 'g'];
  String _selectedGram = '';
  double _selectedQuantity = 1.0;

  void _incrementQuantity() {
    setState(() {
      _selectedQuantity += _selectedGram == '인분' ? 0.5 : 1.0;
      _controller.text = _selectedGram == '인분'
          ? _selectedQuantity.toString()
          : _selectedQuantity.toStringAsFixed(0);
    });
  }

  void _decrementQuantity() {
    if (_selectedQuantity > 0.5) {
      setState(() {
        _selectedQuantity -= _selectedGram == '인분' ? 0.5 : 1.0;
        _controller.text = _selectedGram == '인분'
            ? _selectedQuantity.toString()
            : _selectedQuantity.toStringAsFixed(0);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedMeal = _meals[0];
    _selectedGram = _grams[0];
    setState(() {
      _controller.text = _selectedGram == '인분'
          ? _selectedQuantity.toString()
          : _selectedQuantity.toStringAsFixed(0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> addIngestion({
    required int times,
    required String foodName,
    required double servingSize,
    required double totalIngestionSize,
    required double calories,
    required double carbohydrate,
    required double protein,
    required double fat,
    required double sugars,
    required double salt,
    required double cholesterol,
    required double saturatedFattyAcid,
    required double transFattyAcid,
    required DateTime date,
  }) async {
    final url = Uri.parse('$baseUrl/ingestion');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'times': times,
        'foodName': foodName,
        'servingSize': servingSize,
        'totalIngestionSize': totalIngestionSize,
        'calories': calories,
        'carbohydrate': carbohydrate,
        'protein': protein,
        'fat': fat,
        'sugars': sugars,
        'salt': salt,
        'cholesterol': cholesterol,
        'saturatedFattyAcid': saturatedFattyAcid,
        'date': date.toUtc().toIso8601String().split('T').first,
      }),
    );

    if (response.statusCode == 200) {
      print('식사 기록 성공');
      print(jsonEncode(<String, dynamic>{
        'times': times,
        'foodName': foodName,
        'servingSize': servingSize,
        'totalIngestionSize': totalIngestionSize,
        'calories': calories,
        'carbohydrate': carbohydrate,
        'protein': protein,
        'fat': fat,
        'sugars': sugars,
        'salt': salt,
        'cholesterol': cholesterol,
        'saturatedFattyAcid': saturatedFattyAcid,
        'date': date.toUtc().toIso8601String().split('T').first,
      }));
    } else {
      throw Exception('식사 기록 실패');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: Container(
        height: 530,
        padding: const EdgeInsets.all(30.0),
        decoration: const BoxDecoration(
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
                  widget.food.name.length > 12
                      ? '${widget.food.name.substring(0, 12)}···'
                      : widget.food.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.food.servingSize.toStringAsFixed(0)}g',
                  style: const TextStyle(fontSize: 12),
                ),
                Expanded(
                  child: Text(
                    '${(_selectedGram == '인분' ? widget.food.calories * _selectedQuantity : widget.food.calories * _selectedQuantity / widget.food.servingSize).toStringAsFixed(0)} kcal',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                    alignment: Alignment.center,
                    width: screenWidth * 0.22,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFD9D9D9),
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
                          .map(
                              (e) => DropdownMenuItem(child: Text(e), value: e))
                          .toList(),
                      borderRadius: BorderRadius.circular(8),
                    ))),
                SizedBox(width: 5),
                Container(
                  alignment: Alignment.center,
                  width: screenWidth * 0.35,
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
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove,
                            size: 20, color: Color(0xFFD9D9D9)),
                        onPressed: () {
                          _decrementQuantity();
                        },
                      ),
                      Container(
                        width: screenWidth * 0.075,
                        child: TextField(
                          controller: _controller,
                          onChanged: (value) {
                            setState(() {
                              _selectedQuantity = double.parse(value);
                            });
                          },
                          textAlign: TextAlign.center,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(border: InputBorder.none),
                        ),
                      ),
                      IconButton(
                          icon: Icon(Icons.add,
                              size: 20, color: Color(0xFFD9D9D9)),
                          onPressed: () {
                            _incrementQuantity();
                          }),
                    ],
                  ),
                ),
                SizedBox(width: 5),
                Container(
                    alignment: Alignment.center,
                    width: screenWidth * 0.22,
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
                          if (_selectedGram == '인분') {
                            _selectedQuantity = 1.0;
                            _controller.text = _selectedQuantity.toString();
                          } else {
                            _selectedQuantity = widget.food.servingSize;
                            _controller.text =
                                _selectedQuantity.toStringAsFixed(0);
                          }
                        });
                      },
                      items: _grams
                          .map(
                              (e) => DropdownMenuItem(child: Text(e), value: e))
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
                Text(
                    widget.food.carbohydrate == 9999999
                        ? '정보없음'
                        : '${(_selectedGram == '인분' ? widget.food.carbohydrate * _selectedQuantity : widget.food.carbohydrate * _selectedQuantity / widget.food.servingSize).toStringAsFixed(0)}g',
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
                  child: Text(
                      widget.food.sugars == 9999999
                          ? '정보없음'
                          : '${(_selectedGram == '인분' ? widget.food.sugars * _selectedQuantity : widget.food.sugars * _selectedQuantity / widget.food.servingSize).toStringAsFixed(0)}g',
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
                Text(
                    widget.food.protein == 9999999
                        ? '정보없음'
                        : '${(_selectedGram == '인분' ? widget.food.protein * _selectedQuantity : widget.food.protein * _selectedQuantity / widget.food.servingSize).toStringAsFixed(0)}g',
                    style: TextStyle(fontSize: 16)),
              ],
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('지방', style: TextStyle(fontSize: 16)),
                Text(
                    widget.food.fat == 9999999
                        ? '정보없음'
                        : '${(_selectedGram == '인분' ? widget.food.fat * _selectedQuantity : widget.food.fat * _selectedQuantity / widget.food.servingSize).toStringAsFixed(0)}g',
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
                      widget.food.saturatedFattyAcid == 9999999
                          ? '정보없음'
                          : '${(_selectedGram == '인분' ? widget.food.saturatedFattyAcid * _selectedQuantity : widget.food.saturatedFattyAcid * _selectedQuantity / widget.food.servingSize).toStringAsFixed(0)}g',
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
                  child: Text(
                      widget.food.transFattyAcid == 9999999
                          ? '정보없음'
                          : '${(_selectedGram == '인분' ? widget.food.transFattyAcid * _selectedQuantity : widget.food.transFattyAcid * _selectedQuantity / widget.food.servingSize).toStringAsFixed(0)}g',
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
                Text(
                    widget.food.salt == 9999999
                        ? '정보없음'
                        : '${(_selectedGram == '인분' ? widget.food.salt * _selectedQuantity : widget.food.salt * _selectedQuantity / widget.food.servingSize).toStringAsFixed(0)}g',
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
                  addIngestion(
                    times: _meals.indexOf(_selectedMeal),
                    foodName: widget.food.name,
                    servingSize: widget.food.servingSize,
                    totalIngestionSize: _selectedGram == '인분'
                        ? widget.food.servingSize * _selectedQuantity
                        : _selectedQuantity,
                    calories: _selectedGram == '인분'
                        ? widget.food.calories * _selectedQuantity
                        : widget.food.calories *
                            _selectedQuantity /
                            widget.food.servingSize,
                    carbohydrate: widget.food.carbohydrate >= 9999999
                        ? 9999999
                        : _selectedGram == '인분'
                            ? widget.food.carbohydrate * _selectedQuantity
                            : widget.food.carbohydrate *
                                _selectedQuantity /
                                widget.food.servingSize,
                    protein: widget.food.protein >= 9999999
                        ? 9999999
                        : _selectedGram == '인분'
                            ? widget.food.protein * _selectedQuantity
                            : widget.food.protein *
                                _selectedQuantity /
                                widget.food.servingSize,
                    fat: widget.food.fat >= 9999999
                        ? 9999999
                        : _selectedGram == '인분'
                            ? widget.food.fat * _selectedQuantity
                            : widget.food.fat *
                                _selectedQuantity /
                                widget.food.servingSize,
                    sugars: widget.food.sugars >= 9999999
                        ? 9999999
                        : _selectedGram == '인분'
                            ? widget.food.sugars * _selectedQuantity
                            : widget.food.sugars *
                                _selectedQuantity /
                                widget.food.servingSize,
                    salt: widget.food.salt >= 9999999
                        ? 9999999
                        : _selectedGram == '인분'
                            ? widget.food.salt * _selectedQuantity
                            : widget.food.salt *
                                _selectedQuantity /
                                widget.food.servingSize,
                    cholesterol: widget.food.cholesterol >= 9999999
                        ? 9999999
                        : _selectedGram == '인분'
                            ? widget.food.cholesterol * _selectedQuantity
                            : widget.food.cholesterol *
                                _selectedQuantity /
                                widget.food.servingSize,
                    saturatedFattyAcid: widget.food.saturatedFattyAcid >=
                            9999999
                        ? 9999999
                        : _selectedGram == '인분'
                            ? widget.food.saturatedFattyAcid * _selectedQuantity
                            : widget.food.saturatedFattyAcid *
                                _selectedQuantity /
                                widget.food.servingSize,
                    transFattyAcid: widget.food.transFattyAcid >= 9999999
                        ? 9999999
                        : _selectedGram == '인분'
                            ? widget.food.transFattyAcid * _selectedQuantity
                            : widget.food.transFattyAcid *
                                _selectedQuantity /
                                widget.food.servingSize,
                    date: widgetSelectedDate.toUtc(),
                  );
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
      ),
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
  Map<String, Food> foodInfo = {};
  String searchText = '';

  Future<void> searchFood(String food) async {
    final response = await http.get(
      Uri.parse('$baseUrl/foods/$food'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    final decodedResponse = utf8.decode(response.bodyBytes);

    if (response.statusCode == 200) {
      final data = json.decode(decodedResponse) as List;

      List processedData = data.map((item) {
        return item['name'];
      }).toList();

      setState(() {
        searchResults = processedData;
      });

      for (int i = 0; i < data.length; i++) {
        String jsonData = json.encode(data[i]);
        Map<String, dynamic> foodMap = jsonDecode(jsonData);
        Food food = Food.fromJson(foodMap);
        foodsInfo[i] = food;
      }
    } else {
      throw Exception('Failed to load foods');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize14 = screenWidth * 0.035;
    double fontSize12 = screenWidth * 0.03;
    double fontSize10 = screenWidth * 0.025;
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
                onPressed: () async {
                  searchFood(searchText);
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
            Food? food = foodsInfo[index];
            if (food == null) {
              return SizedBox();
            } else {
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
                color: AppTheme.pastelBlue.withOpacity(0.5),
                child: ListTile(
                  onTap: () {
                    showCustomModalBottomSheet(context, food);
                  },
                  title: Row(children: [
                    Text(
                        food.name.length > 17
                            ? food.name.substring(0, 17) + '···'
                            : food.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: fontSize14, fontWeight: FontWeight.bold)),
                    SizedBox(width: 5),
                    Text('${food?.servingSize.toStringAsFixed(0)}g',
                        style: TextStyle(fontSize: fontSize10)),
                  ]),
                  subtitle: Text(
                      '탄수화물 ${food?.carbohydrate == 9999999.0 ? "정보없음" : "${food?.carbohydrate.toStringAsFixed(0)}g"} 단백질 ${food?.protein == 9999999.0 ? "정보없음" : "${food?.protein.toStringAsFixed(0)}g"} 지방 ${food?.fat == 9999999.0 ? "정보없음" : "${food?.fat.toStringAsFixed(0)}g"}',
                      style: TextStyle(fontSize: fontSize12)),
                  trailing: Text('${food?.calories.toStringAsFixed(0)}kcal',
                      style:
                          TextStyle(fontSize: fontSize14, fontWeight: FontWeight.bold)),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
