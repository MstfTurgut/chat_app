import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {

  const ChatBubble({super.key, required this.text, required this.time, required this.belongToCurrentProfile});

  final String text;
  final String time;
  final bool belongToCurrentProfile;

  @override
  Widget build(BuildContext context) {


    return Container(
      constraints: const BoxConstraints(maxWidth: 260),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: belongToCurrentProfile?Colors.amber:Colors.orange.shade600,
        borderRadius: BorderRadius.circular(10),),
        child: Column(
          crossAxisAlignment:
              (belongToCurrentProfile)
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
          children: [
          Text(text,style: const TextStyle(fontSize: 17),),
          const SizedBox(height: 2,),
          Text(time,style: TextStyle(color: Colors.grey.shade700),),
        ],)
    );
  }
}