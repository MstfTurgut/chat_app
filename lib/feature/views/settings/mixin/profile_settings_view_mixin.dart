import 'dart:io';

import 'package:chat_app/feature/views/settings/profile_settings_view.dart';
import 'package:flutter/material.dart';

import '../../../../product/error_dialog.dart';
import '../../../view-models/settings/profile_settings_view_model.dart';

mixin ProfileSettingsViewMixin on State<ProfileSettingsView> {
  final profileSettingsViewModel = ProfileSettingsViewModel();

  File? image;

  String basicPhotoUrl =
      'https://firebasestorage.googleapis.com/v0/b/chat-app-demo-7ebb6.appspot.com/o/profilePhotos%2Fprofile.jpg?alt=media&token=c46cf299-2000-44b9-a2ff-0f7388584299';

  Future<void> changePhotoAndExit() async {

    if(!mounted) return;
    Navigator.pop(context);

    try {
      if (widget.currentProfile.profilePhotoUrl != basicPhotoUrl) {
        await profileSettingsViewModel.deleteOldProfilePhotoFromStorage(
            widget.currentProfile.profilePhotoUrl);
      }

      String profilePhotoUrl =
          await profileSettingsViewModel.putImageToStorage(image!);

      await profileSettingsViewModel.changeCurrentProfilePhoto(
          widget.currentProfile, profilePhotoUrl);
    } catch (e) {
      await showErrorDialog(Text('$e'), context);
    }


  }
}
