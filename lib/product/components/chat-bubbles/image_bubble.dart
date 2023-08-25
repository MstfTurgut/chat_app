import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageBubble extends StatelessWidget {
  const ImageBubble({super.key, required this.imageUrl, this.text , required this.time,required this.toGroup,this.senderEmail, required this.belongToCurrentProfile});

  final String imageUrl;
  final String? text;
  final String time;
  final bool toGroup;
  final String? senderEmail;
  final bool belongToCurrentProfile;

  @override
  Widget build(BuildContext context) {

    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: belongToCurrentProfile?Colors.amber:Colors.orange.shade600,
        borderRadius: BorderRadius.circular(10),),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          (toGroup)?Padding(
            padding: const EdgeInsets.only(top: 1,bottom: 6 , left: 5),
            child: Text('$senderEmail',style: const TextStyle(color: Colors.black54),),
          ):const SizedBox(width: 0,),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.fitWidth, )),
            
          (text != null && text!.isNotEmpty)?const SizedBox(height: 4,):const SizedBox.shrink(),
          (text != null && text!.isNotEmpty)?Text(text!,style: const TextStyle(fontSize: 17),):const SizedBox.shrink(),
          const SizedBox(height: 2,),
          Align(
            alignment: Alignment.centerRight,
            child: Text(time,style: TextStyle(color: Colors.grey.shade700),)),
        ],)
    );
  }
}