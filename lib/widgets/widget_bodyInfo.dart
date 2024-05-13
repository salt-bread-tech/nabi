import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/service_user.dart';
import '../services/globals.dart' as globals;

class BodyInfoEditorDialog extends StatefulWidget {
  @override
  _BodyInfoEditorDialogState createState() => _BodyInfoEditorDialogState();
}

class _BodyInfoEditorDialogState extends State<BodyInfoEditorDialog> {
  DateTime selectedDate = DateTime.tryParse(globals.birth ?? '') ?? DateTime.now();
  String? selectedGender = globals.gender;

  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController heightController = TextEditingController(text: '${globals.height}');
  final TextEditingController weightController = TextEditingController(text: '${globals.weight}');

  List<String> genders = ['여성', '남성'];

  @override
  void initState() {
    super.initState();
    birthDateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    genderController.text = selectedGender ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      contentPadding: EdgeInsets.all(20),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('정보 수정하기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 24),
            _buildFirstFields(),
            SizedBox(height: 16),
            _buildSecondFields(),
            SizedBox(height: 24),
            _buildUpdateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFirstFields() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text('생년월일', style: TextStyle(fontSize: 12)),
              _buildDatePicker(),
            ],
          ),
        ),
        SizedBox(width: 20),
        Expanded(
          child: Column(
            children: [
              Text('성별', style: TextStyle(fontSize: 12)),
              _buildGenderPicker(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecondFields() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text('키', style: TextStyle(fontSize: 12)),
              _buildTextField('cm', heightController),
            ],
          ),
        ),
        SizedBox(width: 16),
        Expanded(child: Column(
            children: [
            Text('몸무게', style: TextStyle(fontSize: 12)),
          _buildTextField('kg', weightController),
        ],
    ),
    ),
    ],
    );

  }


  Widget _buildTextField(String suffix, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        suffixText: suffix,
        border: OutlineInputBorder(  //기본(비활성화) 상태
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.grey[500]!,
          ),
        ),
        enabledBorder: OutlineInputBorder(  // 활성화 상태
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.grey[400]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(  // 포커스 상태
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.grey[600]!,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 14),
      textAlign: TextAlign.center,
    );
  }

  //생일
  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextField(
          controller: birthDateController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[500]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  //성별
  Widget _buildGenderPicker() {
    return GestureDetector(
      onTap: () => _showGenderPicker(context),
      child: AbsorbPointer(
        child: TextField(
          controller: genderController,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[500]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[400]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[600]!),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  //나이
  int calculateAge(DateTime birthDate) {
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;
    if (birthDate.month > currentDate.month ||
        (birthDate.month == currentDate.month && birthDate.day > currentDate.day)) {
      age--;
    }
    return age;
  }


  void _showGenderPicker(BuildContext context) {
    int selectedIndex = genders.indexOf(selectedGender ?? genders.first);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 200,
          child: CupertinoPicker(
            backgroundColor: Colors.white,
            itemExtent: 32.0,
            onSelectedItemChanged: (int index) {
              setState(() {
                selectedGender = genders[index];
                genderController.text = selectedGender!;
              });
            },
            children: genders.map((String value) => Center(child: Text(value, style: TextStyle(fontSize: 14)))).toList(),
            scrollController: FixedExtentScrollController(initialItem: selectedIndex),
          ),
        );
      },
    );
  }


  Widget _buildUpdateButton() {
    return ElevatedButton(
      onPressed: _updateBodyInfo,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFE0F0FF),
        minimumSize: Size.fromHeight(45),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
        splashFactory: NoSplash.splashFactory,
        enableFeedback: false,
      ),
      child: Text('수정하기', style: TextStyle(color: Colors.black, fontSize: 15)),
    );
  }


  Future<void> _updateBodyInfo() async {
    final gender = selectedGender;
    final birth = DateFormat('yyyy-MM-dd').format(selectedDate);
    final height = double.tryParse(heightController.text);
    final weight = double.tryParse(weightController.text);
    final age = calculateAge(selectedDate);

    if (height != null && weight != null && gender != null) {
      await updateBodyInfo( gender: gender, height: height, weight: weight, birth: birth, age: age);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("정확히 입력해주세요")));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 250,
        color: Colors.white,
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: selectedDate,
          onDateTimeChanged: (DateTime newDate) {
            if (newDate != selectedDate) {
              setState(() {
                selectedDate = newDate;
                birthDateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
              });
            }
          },
        ),
      ),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        birthDateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      });
    }
  }
}
