import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class CustomTextFormField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final double fontSize;
  final InputDecoration? decoration;
  final String? suffixText;
  final String? errorText;

  const CustomTextFormField({
    Key? key,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    required this.keyboardType,
    this.fontSize = 15.0,
    this.decoration,
    this.suffixText,
    this.errorText,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
        decoration: decoration ?? InputDecoration(
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xFF98CBFA)),
          ),
          hintText: hintText,
          suffixText: suffixText,
          errorText: errorText,
          fillColor: Colors.white,
          filled: true,
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        ),
      ),
    );
  }
}


class CustomErrorTextFormField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final double fontSize;
  final InputDecoration? decoration;
  final String? suffixText;
  final String? errorText;

  const CustomErrorTextFormField({
    Key? key,
    required this.hintText,
    required this.controller,
    this.isPassword = false,
    required this.keyboardType,
    this.fontSize = 15.0,
    this.decoration,
    this.suffixText,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: isPassword,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w500,
        ),
        decoration: decoration ?? InputDecoration(
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xFF98CBFA)),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Color(0xFFFF4473), width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.red[500]!, width: 1),
          ),
          hintText: hintText,
          suffixText: suffixText,
          errorText: errorText,
          fillColor: Colors.white,
          filled: true,
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
         //아이콘
          errorStyle: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),
          //suffixIcon: errorText != null ? Icon(Iconsax.danger, color: Colors.red) : null,
        ),
      ),
    );
  }
}
