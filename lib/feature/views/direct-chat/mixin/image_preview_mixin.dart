import 'dart:io';

import 'package:chat_app/feature/views/direct-chat/image_preview.dart';
import 'package:chat_app/product/error_dialog.dart';
import 'package:flutter/material.dart';

import '../../../view-models/direct-chat/chat_view_model.dart';
import '../../../view-models/group-chat/group_chat_view_model.dart';
import '../../../view-models/settings/media_preview_model.dart';

mixin ImagePreviewMixin on State<ImagePreview> {
  final imagePreviewModel = ImagePreviewModel();
  final chatViewModel = ChatViewModel();
  final groupChatViewModel = GroupChatViewModel();
  final captionCtr = TextEditingController();

  Future<void> cropImage() async {
    File? croppedImage = await imagePreviewModel.cropImage(file: widget.media);

    if (croppedImage != null) {
      setState(() {
        widget.media = croppedImage;
      });
    }
  }

  Future<void> sendMedia() async {

    if (!mounted) return;
    Navigator.pop(context);

    try {
      String imageUrl = await imagePreviewModel.putImageToStorage(widget.media);

      if (widget.toGroup) {
        await groupChatViewModel.sendMessage(
            chatRoomId: widget.chatRoomId!,
            imageUrl: imageUrl,
            text: captionCtr.text);
      } else {
        await chatViewModel.sendMessage(
            receiverProfile: widget.receiverProfile!,
            imageUrl: imageUrl,
            text: captionCtr.text);
      }

    } catch (e) {
      await showErrorDialog(Text('$e'), context);
    }
  }
}
