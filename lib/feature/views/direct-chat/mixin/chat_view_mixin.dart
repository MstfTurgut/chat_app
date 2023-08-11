import 'package:chat_app/product/error_dialog.dart';
import 'package:flutter/material.dart';
import '../../../view-models/direct-chat/chat_view_model.dart';
import '../chat_view.dart';

mixin ChatViewMixin on State<ChatView> {

  final TextEditingController messageCtr = TextEditingController();

  final chatViewModel = ChatViewModel();

  @override
  void dispose() {
    messageCtr.dispose();
    super.dispose();
  }

  String titleTrimmer(String text) {
    if(text.length > 15) {
      return text.replaceRange(15, null, '...');
    } else {
      return text;
    }

  }
  

  Future<void> sendMessage() async {
    if (messageCtr.text.isNotEmpty) {
      try {
  await chatViewModel.sendMessage(
      text: messageCtr.text, receiverProfile: widget.receiverProfile);
  messageCtr.clear();
} catch (e) {
    await showErrorDialog(Text('$e'), context);
}
    }
  }

  late Offset tapPosition;

  void storePosition(TapDownDetails details) {
    tapPosition = details.globalPosition;
  }


}