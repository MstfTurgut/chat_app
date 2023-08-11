import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  const MyTextField({super.key, required this.controller, required this.hintText, required this.obscureText, this.keyboardType, required this.fillColor, required this.borderRadius, required this.cursorColor, required this.hintTextColor, required this.textColor});

  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Color fillColor;
  final double borderRadius;
  final Color cursorColor;
  final Color hintTextColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: TextField(
        style: TextStyle(color: textColor),
        cursorWidth: 1,
        keyboardType: keyboardType,
        cursorColor: cursorColor,
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(left: 10),
          filled: true,
          fillColor: fillColor,
          hintText: hintText,
          hintStyle: TextStyle(color: hintTextColor),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: Colors.black)
          ),
        ),
      ),
    );
  }
}