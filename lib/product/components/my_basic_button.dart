import 'package:flutter/material.dart';

class MyBasicButton extends StatelessWidget {
  const MyBasicButton({super.key, required this.title, this.onPressed});

  final String title;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: ElevatedButton(
          onPressed: onPressed,
          child: Text(
            title,
            style: const TextStyle(color: Colors.black ,fontSize: 15),
          ),
          ),
    );
  }
}
