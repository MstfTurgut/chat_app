import 'package:flutter/material.dart';

class GroupChatBubble extends StatelessWidget {
  const GroupChatBubble(
      {super.key,
      required this.text,
      required this.time,
      required this.belongToCurrentProfile,
      required this.senderEmail});

  final String text;
  final String time;
  final bool belongToCurrentProfile;
  final String senderEmail;

  @override
  Widget build(BuildContext context) {

    return Container(
        constraints: const BoxConstraints(maxWidth: 260),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: belongToCurrentProfile?Colors.amber:Colors.orange.shade600,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 30 , bottom: 2),
                  child: Text(
                    senderEmail,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  text,
                  style: const TextStyle(fontSize: 17),
                ),
                const SizedBox(height: 16,)
              ],
            ),
            Positioned(
                  bottom: -2,
                  right: -2,
                  child: Text(
                    time,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                )
          ],
        ));
  }
}
