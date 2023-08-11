import 'dart:io';
import 'package:chat_app/product/components/my_text_field.dart';
import 'package:flutter/material.dart';
import '../../model/profile.dart';
import 'mixin/image_preview_mixin.dart';

// ignore: must_be_immutable
class ImagePreview extends StatefulWidget {
  
  ImagePreview(
      {super.key,
      required this.media,
      this.receiverProfile,
      this.chatRoomId,
      required this.toGroup});

  final Profile? receiverProfile;
  final String? chatRoomId;
  File media;
  final bool toGroup;

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> with ImagePreviewMixin{
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, actions: [
        IconButton(
            onPressed: cropImage,
            icon: const Icon(Icons.crop)),
      ]),
      body: Column(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // MEDIA
          Expanded(
              child: Center(
                  child: Image.file(
            widget.media,
            fit: BoxFit.fitWidth,
          ))),
          // TEXTFIELD
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: MyTextField(
                textColor: Colors.white,
                hintTextColor: Colors.white,
                cursorColor: Colors.white,
                borderRadius: 15,
                fillColor: const Color.fromARGB(86, 255, 193, 7),
                controller: captionCtr,
                hintText: 'Add some text..',
                obscureText: false),
          ),
          // SEND BUTTON
          Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.symmetric(vertical: 20),
            child: GestureDetector(
              onTap: sendMedia,
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(25)),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
