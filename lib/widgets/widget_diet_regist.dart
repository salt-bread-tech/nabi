import 'package:flutter/material.dart';

class CustomBottomSheet {
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              left: 20,
              top: 20,
              right: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                _buildTitleSection(),
                _buildServingSizeSection(),
                _buildNutrientInfo('탄수화물', '20g', '당류', '5g'),
                _buildNutrientInfo('단백질', '8g'),
                _buildNutrientInfo('지방', '8g', '포화지방', '1g'),
                _buildNutrientInfo('나트륨', '4g'),
                _buildNutrientInfo('콜레스테롤', '0.3g'),
                _buildActionButton(context),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildTitleSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '계란후라이 건자극',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          '146 kcal',
          style: TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  static Widget _buildServingSizeSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Here would go your Dropdown or other widgets
      ],
    );
  }

  static Widget _buildNutrientInfo(String nutrientName, String value, [String? additionalNutrientName, String? additionalValue]) {
    List<Widget> children = [
      Text(nutrientName, style: TextStyle(fontSize: 16)),
      Text(value, style: TextStyle(fontSize: 16)),
    ];

    if (additionalNutrientName != null && additionalValue != null) {
      children.addAll([
        SizedBox(height: 8),
        Text(additionalNutrientName, style: TextStyle(fontSize: 16)),
        Text(additionalValue, style: TextStyle(fontSize: 16)),
      ]);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      ),
    );
  }

  static Widget _buildActionButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // Add your action here
          },
          child: Text('기록하기'),
        ),
      ),
    );
  }
}
