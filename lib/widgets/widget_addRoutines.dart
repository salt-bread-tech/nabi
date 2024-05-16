import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../services/service_routine.dart';


class AddRoutineWidget extends StatefulWidget {
  @override
  _AddRoutineWidgetState createState() => _AddRoutineWidgetState();
}

class _AddRoutineWidgetState extends State<AddRoutineWidget> {
  final TextEditingController _routineController = TextEditingController();
  final TextEditingController _maxTermController = TextEditingController();  // Controller for max term input
  int _selectedFrequencyValue = 1;
  Color _selectedColor = Color(0xFFFFDFEB);
  String startDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  int _selectedMaxTerm = 1;



  void _registerRoutine() async {

    String colorCodeWithoutAlpha = _selectedColor.value.toRadixString(16).substring(2).toUpperCase();
    int maxTerm = int.tryParse(_maxTermController.text) ?? 1;

    try {
      await registerDailyRoutine(
          routineName: _routineController.text,
          maxPerform: _selectedFrequencyValue,
          startDate: startDate,
          colorCode: colorCodeWithoutAlpha,
        maxTerm: maxTerm,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("데일리 루틴 등록 성공")));
      print(' Name: ${_routineController.text}, Max Perform: ${_selectedFrequencyValue}, Color: ${colorCodeWithoutAlpha}, Date: ${startDate}, maxTerm : $maxTerm');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("데일리 루틴 등록 실패: $e")));
    }
  }


  Widget firstField(){
    return Row(
      children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('습관명',style: TextStyle(fontSize: 13),),
            _buildRoutineNameInput()
          ],
        ),
        ),
        SizedBox(width: 20),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text('반복 할 횟수',style: TextStyle(fontSize: 13),),
        _buildMaxTermInput(),
        ],))
      ],
    );
  }

  Widget _buildRoutineNameInput(){
    return TextField(
      autocorrect: false,
      decoration: InputDecoration(
        hintText: '습관명 입력하기',
        border: InputBorder.none,
        contentPadding: EdgeInsets.only(bottom: 11, top: 11, right: 15),
      ),
      controller: _routineController,
    );
  }
  Widget _buildMaxTermInput() {
    return TextField(
      autocorrect: false,
      keyboardType: TextInputType.number, // Ensure numeric input
      decoration: InputDecoration(
        hintText: '횟수',
        border: InputBorder.none,
        contentPadding: EdgeInsets.only(bottom: 11, top: 11, right: 15),
      ),
      controller: _maxTermController,
    );
  }

  void _showFrequencyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          child: CupertinoPicker(
            backgroundColor: CupertinoColors.white,
            onSelectedItemChanged: (int value) {
              setState(() {
                _selectedFrequencyValue = value + 1;
              });
            },
            itemExtent: 32.0,
            children: List<Widget>.generate(8, (int index) {
              return Center(
                child: Text('${index + 1}'),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildFrequencyDisplay(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFrequencyPicker(context),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 3.0,horizontal: 8),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$_selectedFrequencyValue',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    final List<Color> _colorOptions = [
      Color(0xFFFFDFEB),
      Color(0xFFFFAAD3),
      Color(0xFFFFE500),
      Color(0xFFD3EAFF),
      Color(0xFF6696DE),
      Color(0xFFE8DAFF),
      Color(0xFF9D79D8),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _colorOptions.map((color) {
        bool isSelected = _selectedColor == color;
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
          },
          child: Container(
            padding: EdgeInsets.all(1),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.grey : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: CircleAvatar(
              backgroundColor: color,
              radius: 13,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20.0),
              children: [
                firstField(),
                SizedBox(height: 10,),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('횟수',style: TextStyle(fontSize: 13),),
                        SizedBox(height: 5),
                        _buildFrequencyDisplay(context),
                      ],
                    ),
                    SizedBox(width: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('색',style: TextStyle(fontSize: 13),),
                        SizedBox(height: 5),
                        _buildColorPicker(),
                      ],
                    ),
                    Spacer(),
                    IconButton(onPressed: _registerRoutine, icon: Icon(Iconsax.send_15))
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
