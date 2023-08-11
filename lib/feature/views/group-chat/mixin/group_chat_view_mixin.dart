import 'package:chat_app/product/error_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../model/group.dart';
import '../../../model/profile.dart';
import '../../../view-models/group-chat/group_chat_view_model.dart';
import '../group_chat_view.dart';
import '../group_info_view.dart';

mixin GroupChatViewMixin on State<GroupChatView> {
  final TextEditingController messageCtr = TextEditingController();

  final groupChatViewModel = GroupChatViewModel();

  late Offset tapPosition;

  @override
  void dispose() {
    messageCtr.dispose();
    super.dispose();
  }

  void storePosition(TapDownDetails details) {
    tapPosition = details.globalPosition;
  }

  String titleTrimmer(String text) {
    if (text.length > 15) {
      return text.replaceRange(15, null, '...');
    } else {
      return text;
    }
  }

  Future<void> sendMessage() async {
    if (messageCtr.text.isNotEmpty) {
      try {
        await groupChatViewModel.sendMessage(
            text: messageCtr.text, chatRoomId: widget.groupId);
        messageCtr.clear();
      } catch (e) {

        await showErrorDialog(Text('$e'), context);
      }
    }
  }

  Future<void> exitGroup() async {
    await Future.delayed(Duration.zero);
    bool? confirm = await showMyConfirmDialog();

    if (confirm == true) {
      if (!mounted) return;
      Navigator.pop(context);
      try {
        await groupChatViewModel.exitGroup(widget.groupId);
      } catch (e) {
        if (!mounted) return;
        await showErrorDialog(Text('$e'), context);
      }
    }
  }

  Future<void> goToGroupInfoView(Group group) async {
    List<Profile> groupMembers =
        await groupChatViewModel.getGroupMembers(widget.groupId);

    bool isCurrentProfileAdmin = groupChatViewModel.isAdmin(
        group.adminIdList, FirebaseAuth.instance.currentUser!.uid);

    if (!mounted) return;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => GroupInfoView(
                groupMembers: groupMembers,
                group: group,
                isCurrentProfileAdmin: isCurrentProfileAdmin)));
  }

  Future<bool?> showMyConfirmDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Do you really want to exit group ?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}
