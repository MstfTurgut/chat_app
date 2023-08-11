import 'package:flutter/material.dart';

class MyAuthButton extends StatelessWidget {
  const MyAuthButton({super.key, required this.onPressed, required this.title});

  final void Function() onPressed;
  final String title;


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
        onPressed: onPressed, child: Center(
        child: Text(title,style: const TextStyle(color: Colors.white),),
      )),
    );
  }
}