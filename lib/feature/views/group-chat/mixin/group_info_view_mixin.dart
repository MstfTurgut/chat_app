import 'dart:io';

import 'package:chat_app/feature/views/group-chat/group_info_view.dart';
import 'package:flutter/material.dart';

import '../../../../product/error_dialog.dart';
import '../../../model/profile.dart';
import '../../../view-models/group-chat/group_chat_view_model.dart';
import '../../../view-models/group-chat/group_info_view_model.dart';
import '../../../view-models/settings/profile_settings_view_model.dart';

mixin GroupInfoViewMixin on State<GroupInfoView> {
  final profileSettingsViewModel = ProfileSettingsViewModel();
  final groupInfoViewModel = GroupInfoViewModel();
  final groupChatViewModel = GroupChatViewModel();

  final formStateKey = GlobalKey<FormState>();
  final newGroupNameCtr = TextEditingController();

  String? newGroupName;
  File? image;
  String basicGroupPhotoUrl =
      'https://firebasestorage.googleapis.com/v0/b/chat-app-demo-7ebb6.appspot.com/o/groupProfilePhotos%2Fgroup_default.png?alt=media&token=d8255e17-cb5a-44ec-bfbc-8258d00574db';

  void changeGroupName() async {
    await showNewGroupNameDialog();
  }

  Future<void> showNewGroupNameDialog() async {
    bool isClicked = false;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('New Group Name'),
                Form(
                  key: formStateKey,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field cannot be blank';
                      } else {
                        return null;
                      }
                    },
                    controller: newGroupNameCtr,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel')),
            TextButton(
              onPressed: (!isClicked)
                  ? () async {
                      if (formStateKey.currentState!.validate()) {
                        isClicked = true;
                        if (!mounted) return;
                        Navigator.pop(context);
                        await groupInfoViewModel.changeGroupName(
                            newGroupNameCtr.text, widget.group.groupId);

                        newGroupName = newGroupNameCtr.text;

                        setState(() {});

                      }
                    }
                  : null,
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> showMyMakeAdminConfirmDialog(
      Profile profile, String groupId) async {
    bool isClicked = false;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Make ${profile.email} group admin ?'),
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
              onPressed: (!isClicked)
                  ? () async {
                      isClicked = true;
                      if (!mounted) return;
                      Navigator.of(context).pop(true);
                      try {
                        await groupInfoViewModel.makeAdmin(
                            profile.email, profile.uid, groupId);
                      } catch (e) {
                        await showErrorDialog(Text('$e'), context);
                      }
                    }
                  : null,
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> showMyRemoveProfileConfirmDialog(
      Profile profile, String groupId) async {
    bool isClicked = false;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Remove ${profile.email} ?'),
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
              onPressed: (!isClicked)
                  ? () async {
                      isClicked = true;
                      if (!mounted) return;
                      Navigator.of(context).pop(true);
                      await groupInfoViewModel.removeProfile(
                          groupId, profile.uid);
                    }
                  : null,
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
