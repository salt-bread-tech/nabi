import 'dart:async';

import 'package:doctor_nyang/assets/theme.dart';
import 'package:doctor_nyang/screen/screen_food_search.dart';
import 'package:doctor_nyang/services/globals.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/model_diet.dart';
import '../services/urls.dart';
import '../widgets/widget_delete.dart';
import '../widgets/widget_diet.dart';
import '../widgets/widget_weekly_calendar.dart';

class DietSchedule extends StatefulWidget {
  @override
  _DietScheduleState createState() => _DietScheduleState();
}

class _DietScheduleState extends State<DietSchedule> {
  List<dynamic> dietSchedule = [];
  List<dynamic> ingestionSchedule = [];

  void _handleDateChange(DateTime newDate) {
    setState(() {
      selectedDate = newDate.toUtc();
      fetchIngestion();
      fetchDietSchedule();
    });
  }

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now().toUtc();
    fetchIngestion();
    fetchDietSchedule();
    _controller.text = _selectedGram == '인분'
        ? _selectedQuantity.toString()
        : _selectedQuantity.toStringAsFixed(0);
    setState(() {
      _selectedMeal = _meals[0];
      _selectedGram = _grams[0];
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> fetchDietSchedule() async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.toUtc());
    final String url = '$baseUrl/diet/$formattedDate';

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
        List<dynamic> diet = json.decode(responseBody);

        setState(() {
          dietSchedule = diet;
        });

        dietSchedule.sort((a, b) =>
            a['ingestionTimes'].compareTo(b['ingestionTimes']));

        print(dietSchedule);
      } else {
        print('일정 조회 실패');
      }
    } catch (e) {
      print('네트워크 오류 $e');
    }
  }

  FutureOr<Ingestion?> fetchIngestion() async {
    final String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate.toUtc());
    final String url = '$baseUrl/ingestion/total/$formattedDate';

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
        Map<String, dynamic> ingestion = json.decode(responseBody);

        setState(() {
          ingestionSchedule = [ingestion];
        });
      } else {
        throw Exception('Failed to load ingestion');
      }
    } catch (e) {
      print('error: $e');
    }
  }

  Future<void> updateIngestion({
    required int ingestionId,
    required String date,
    required int times,
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
  }) async {
    final String url = '$baseUrl/ingestion';

    try {
      final response = await http.put(Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({
            'ingestionId': ingestionId,
            'date': date,
            'times': times,
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
            'transFattyAcid': transFattyAcid,
          }));

      if (response.statusCode == 200) {
        print('식단 업데이트 성공');
        fetchIngestion();
        fetchDietSchedule();
      } else {
        print('식단 업데이트 실패');
        print(response.body + 'error');
      }
    } catch (e) {
      print('네트워크 오류 $e');
    }
  }

  Future<void> deleteIngestion(int ingestionId) async {
    final String url = '$baseUrl/ingestion/$ingestionId/delete';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print('식단 삭제 성공');
        fetchIngestion();
        fetchDietSchedule();
      } else {
        print('식단 삭제 실패');
      }
    } catch (e) {
      print('네트워크 오류 $e');
    }
  }

  Color cardColor(int times) {
    if (times == 0) {
      return AppTheme.pastelPink;
    } else if (times == 1) {
      return AppTheme.pastelBlue;
    } else if (times == 2) {
      return AppTheme.pastelGreen;
    } else {
      return AppTheme.pastelYellow;
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

  void showCustomModalBottomSheet(BuildContext context, int id, Food food,
      {required totalIngestionSize}) {
    double screenWidth = MediaQuery.of(context).size.width;
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Container(
                    height: 250,
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
                                food.name.length > 12
                                    ? '${food.name.substring(0, 12)}···'
                                    : food.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${food.servingSize.toStringAsFixed(0)}g',
                                style: const TextStyle(fontSize: 12),
                              ),
                              SizedBox(width: 5),
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
                                        .map((e) => DropdownMenuItem(
                                            child: Text(e), value: e))
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
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove,
                                          size: 20, color: Color(0xFFD9D9D9)),
                                      onPressed: _decrementQuantity,
                                    ),
                                    Container(
                                      width: screenWidth * 0.075,
                                      child: TextField(
                                        controller: _controller,
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedQuantity = double.parse(
                                                value.isEmpty ? '0' : value);
                                          });
                                        },
                                        textAlign: TextAlign.center,
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: true),
                                        decoration: InputDecoration(
                                            border: InputBorder.none),
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
                                          _controller.text =
                                              _selectedQuantity.toString();
                                        } else {
                                          print(food.servingSize);
                                          _selectedQuantity = food.servingSize;
                                          _controller.text = _selectedQuantity
                                              .toStringAsFixed(0);
                                        }
                                      });
                                    },
                                    items: _grams
                                        .map((e) => DropdownMenuItem(
                                            child: Text(e), value: e))
                                        .toList(),
                                    borderRadius: BorderRadius.circular(8),
                                  ))),
                            ],
                          ),
                          SizedBox(height: 20),
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
                              onPressed: () async {
                                double calculate = _selectedGram == '인분'
                                    ? _selectedQuantity *
                                        food.servingSize /
                                        totalIngestionSize
                                    : _selectedQuantity / totalIngestionSize;
                                await updateIngestion(
                                  ingestionId: id,
                                  date: DateFormat('yyyy-MM-dd')
                                      .format(selectedDate.toUtc())
                                      .toString(),
                                  times: _selectedMeal== '아침'
                                      ? 0
                                      : _selectedMeal == '점심'
                                      ? 1
                                      : _selectedMeal == '저녁'
                                      ? 2
                                      : 3,
                                  servingSize: food.servingSize,
                                  totalIngestionSize: _selectedGram == '인분'
                                      ? food.servingSize * _selectedQuantity
                                      : _selectedQuantity,
                                  calories: food.calories >= 9999999
                                      ? 9999999
                                      : food.calories * calculate,
                                  carbohydrate: food.carbohydrate >= 9999999
                                      ? 9999999
                                      : food.carbohydrate * calculate,
                                  protein: food.protein >= 9999999
                                      ? 9999999
                                      : food.protein * calculate,
                                  fat: food.fat >= 9999999
                                      ? 9999999
                                      : food.fat * calculate,
                                  sugars: food.sugars >= 9999999
                                      ? 9999999
                                      : food.sugars * calculate,
                                  salt: food.salt >= 9999999
                                      ? 9999999
                                      : food.salt * calculate,
                                  cholesterol: food.cholesterol >= 9999999
                                      ? 9999999
                                      : food.cholesterol * calculate,
                                  saturatedFattyAcid:
                                      food.saturatedFattyAcid >= 9999999
                                          ? 9999999
                                          : food.saturatedFattyAcid * calculate,
                                  transFattyAcid: food.transFattyAcid >= 9999999
                                      ? 9999999
                                      : food.transFattyAcid * calculate,
                                );
                                print(
                                    'ingedtionId: $id, date: $selectedDate, times: ${_selectedMeal == '아침' ? 0 : _selectedMeal == '점심' ? 1 : _selectedMeal == '저녁' ? 2 : 3}, servingSize: ${food.servingSize}, totalIngestionSize: ${_selectedGram == '인분' ? food.servingSize * _selectedQuantity : _selectedQuantity}, calories: ${_selectedGram == '인분' ? food.calories * _selectedQuantity : food.calories * _selectedQuantity / food.servingSize}, carbohydrate: ${_selectedGram == '인분' ? food.carbohydrate * _selectedQuantity : food.carbohydrate * _selectedQuantity / food.servingSize}, protein: ${_selectedGram == '인분' ? food.protein * _selectedQuantity : food.protein * _selectedQuantity / food.servingSize}, fat: ${_selectedGram == '인분' ? food.fat * _selectedQuantity : food.fat * _selectedQuantity / food.servingSize}, sugars: ${_selectedGram == '인분' ? food.sugars * _selectedQuantity : food.sugars * _selectedQuantity / food.servingSize}, salt: ${_selectedGram == '인분' ? food.salt * _selectedQuantity : food.salt * _selectedQuantity / food.servingSize}, cholesterol: ${_selectedGram == '인분' ? food.cholesterol * _selectedQuantity : food.cholesterol * _selectedQuantity / food.servingSize}, saturatedFattyAcid: ${_selectedGram == '인분' ? food.saturatedFattyAcid * _selectedQuantity : food.saturatedFattyAcid * _selectedQuantity / food.servingSize}, transFattyAcid: ${_selectedGram == '인분' ? food.transFattyAcid * _selectedQuantity : food.transFattyAcid * _selectedQuantity / food.servingSize}');
                                Navigator.pop(context);
                              },
                              child: Text(
                                '기록하기',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ]),
                  ));
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final fontSize = screenSize.width * 0.032;

    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          elevation: 0,
          title: Text(
            '$nickName님의 식단 관리',
            style: TextStyle(color: Colors.black, fontSize: 17),
            textAlign: TextAlign.center,
          ),
          iconTheme: IconThemeData(color: Colors.black),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FoodSearch()),
                );
                fetchIngestion();
                fetchDietSchedule();
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            child: Column(
              children: <Widget>[
                WidgetCalendar(onDateSelected: _handleDateChange),
                SizedBox(height: 20),
                WidgetDiet(
                  onTap: () {},
                  isWidget: false,
                  userCalories: bmr ?? 2000,
                  breakfastCalories: ingestionSchedule.isNotEmpty
                      ? ingestionSchedule[0]['breakfastKcal']
                      : 0,
                  lunchCalories: ingestionSchedule.isNotEmpty
                      ? ingestionSchedule[0]['lunchKcal']
                      : 0,
                  dinnerCalories: ingestionSchedule.isNotEmpty
                      ? ingestionSchedule[0]['dinnerKcal']
                      : 0,
                  snackCalories: ingestionSchedule.isNotEmpty
                      ? ingestionSchedule[0]['snackKcal']
                      : 0,
                  totalProtein: ingestionSchedule.isNotEmpty
                      ? ingestionSchedule[0]['totalProtein']
                      : 0,
                  totalCarb: ingestionSchedule.isNotEmpty
                      ? ingestionSchedule[0]['totalCarbohydrate']
                      : 0,
                  totalFat: ingestionSchedule.isNotEmpty
                      ? ingestionSchedule[0]['totalFat']
                      : 0,
                ),
                SizedBox(height: 20),
                Column(
                  children: List<Widget>.generate(dietSchedule.length, (index) {
                    var diet = dietSchedule[index];
                    return Slidable(
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              flex: 1,
                              onPressed: (context) => {
                                _selectedMeal = _meals[0],
                                _selectedGram = _grams[0],
                                setState(() {
                                  _controller.text = _selectedGram == '인분'
                                      ? _selectedQuantity.toString()
                                      : _selectedQuantity.toStringAsFixed(0);
                                }),
                                showCustomModalBottomSheet(
                                  context,
                                  diet['ingestionId'],
                                  totalIngestionSize:
                                      diet['totalIngestionSize'],
                                  Food(
                                      name: diet['name'],
                                      servingSize: diet['servingSize'],
                                      calories: diet['calories'],
                                      carbohydrate: diet['carbohydrate'],
                                      protein: diet['protein'],
                                      fat: diet['fat'],
                                      sugars: diet['sugars'],
                                      salt: diet['salt'],
                                      cholesterol: diet['cholesterol'],
                                      saturatedFattyAcid:
                                          diet['saturatedFattyAcid'],
                                      transFattyAcid: diet['transFattyAcid']),
                                ),
                              },
                              backgroundColor: Colors.black12,
                              foregroundColor: Colors.white,
                              icon: Iconsax.edit,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                            SlidableAction(
                              flex: 1,
                              onPressed: (context) => {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return DeleteConfirmDialog(
                                          title: '식단 삭제',
                                          content: '이 식단을 정말 삭제하시겠습니까?',
                                          onConfirm: () {
                                            deleteIngestion(
                                                diet['ingestionId']);
                                          });
                                    })
                              },
                              backgroundColor: Color(0xFFFF5050),
                              foregroundColor: Colors.white,
                              icon: Iconsax.trash,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20)),
                            ),
                          ],
                        ),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: cardColor(diet['ingestionTimes']).withOpacity(0.4),
                          elevation: 0,
                          child: ListTile(
                            title: Row(
                              children: [
                                Text(
                                    diet['name'].length > 14
                                        ? '${diet['name'].substring(0, 14)}···'
                                        : diet['name'],
                                    style: TextStyle(
                                        fontSize: fontSize,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(width: 5),
                                Text(
                                    '${diet['totalIngestionSize'].toStringAsFixed(0)}g',
                                    style: TextStyle(fontSize: fontSize)),
                              ],
                            ),
                            subtitle: Text(
                                '탄수화물 ${diet['carbohydrate'] >= 9999999.0 ? "-g" : "${diet['carbohydrate'].toStringAsFixed(0)}g"} 단백질 ${diet['protein'] >= 9999999.0 ? "-g" : "${diet['protein'].toStringAsFixed(0)}g"} 지방 ${diet['fat'] >= 9999999.0 ? "-g" : "${diet['fat'].toStringAsFixed(0)}g"}',
                                style: TextStyle(fontSize: fontSize)),
                            trailing: Text(
                                '${diet['calories'].toStringAsFixed(0)}kcal',
                                style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ));
                  }),
                ),
              ],
            ),
          ),
        ));
  }
}
