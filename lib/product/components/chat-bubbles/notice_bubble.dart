import 'package:flutter/material.dart';

class NoticeBubble extends StatelessWidget {
  const NoticeBubble({super.key, required this.noticeMessage});

  final String noticeMessage;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
        color: Colors.amber.shade200,
        borderRadius: const BorderRadius.all(Radius.circular(5))
      ),
      child: Text(noticeMessage),
    );
  }
}