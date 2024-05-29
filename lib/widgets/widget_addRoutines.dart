import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../services/service_routine.dart';

class AddRoutineWidget extends StatefulWidget {
  final VoidCallback onRoutineAdded;

  AddRoutineWidget({Key? key, required this.onRoutineAdded}) : super(key: key);

  @override
  _AddRoutineWidgetState createState() => _AddRoutineWidgetState();
}

class _AddRoutineWidgetState extends State<AddRoutineWidget> {
  final TextEditingController _routineController = TextEditingController();
  final TextEditingController _maxTermController = TextEditingController(); // Controller for max term input
  int _selectedFrequencyValue = 1;
  Color _selectedColor = Color(0xFFFFDFEB);
  String startDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
  int _selectedMaxTerm = 1;

  void _registerRoutine() async {
    String colorCodeWithoutAlpha = _selectedColor.value.toRadixString(16)
        .substring(2)
        .toUpperCase();
    int maxTerm = int.tryParse(_maxTermController.text) ?? 1;

    try {
      await registerDailyRoutine(
        routineName: _routineController.text,
        maxPerform: _selectedFrequencyValue,
        startDate: startDate,
        colorCode: colorCodeWithoutAlpha,
        maxTerm: maxTerm,
      );
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("데일리 루틴 등록 성공")));
      widget.onRoutineAdded();
      print(' Name: ${_routineController
          .text}, Max Perform: ${_selectedFrequencyValue}, Color: ${colorCodeWithoutAlpha}, Date: ${startDate}, maxTerm : $maxTerm');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("데일리 루틴 등록 실패: $e")));
    }
  }

  Widget firstField() {
    return Row(
      children: [
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRoutineNameInput()
          ],
        ),
        ),
        SizedBox(width: 20),
        Expanded(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMaxTermInput(),
          ],))
      ],
    );
  }

  Widget _buildRoutineNameInput() {
    return TextField(
      autocorrect: false,
      decoration: InputDecoration(
        hintText: '습관명 입력하기',
        border: InputBorder.none,
        contentPadding: EdgeInsets.only(top: 11, right: 15),
        counter: Offstage(),  // Hides the counter
      ),
      controller: _routineController,
      maxLength: 9,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
    );
  }

  Widget _buildMaxTermInput() {
    return TextField(
      autocorrect: false,
      keyboardType: TextInputType.number, // Ensure numeric input
      decoration: InputDecoration(
        hintText: '1',
        suffixText: '주 동안 반복',
        border: InputBorder.none,
        contentPadding: EdgeInsets.only(bottom: 11, top: 11, right: 60),
      ),
      controller: _maxTermController,
    );
  }

  void _showFrequencyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery
              .of(context)
              .copyWith()
              .size
              .height / 3,
          child: CupertinoPicker(
            backgroundColor: CupertinoColors.white,
            onSelectedItemChanged: (int value) {
              setState(() {
                _selectedFrequencyValue = value + 1;
              });
            },
            itemExtent: 32.0,
            children: List<Widget>.generate(7, (int index) {
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
        padding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 8),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$_selectedFrequencyValue 회',
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
    final double screenWidth = MediaQuery.of(context).size.width;
    final double baseSize = screenWidth / 31;
    final List<Color> _colorOptions = [
      Color(0xFFFFDFEB),
      Color(0xFFFFAAD3),
      Color(0xFFFFE500),
      Color(0xFFD3EAFF),
      Color(0xFF6696DE),
      Color(0xFFE8DAFF),
      Color(0xFF9D79D8),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
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
                radius: baseSize, // Use the calculated base size for the radius
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              firstField(),
              SizedBox(height: 10),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      _buildFrequencyDisplay(context),
                    ],
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5),
                        _buildColorPicker(),
                      ],
                    ),
                  ),
                  IconButton(
                      onPressed: (){_registerRoutine(); Navigator.of(context).pop();},  icon: Icon(Iconsax.send_15))
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
