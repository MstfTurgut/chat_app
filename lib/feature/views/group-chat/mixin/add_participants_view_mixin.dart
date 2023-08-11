

import 'package:chat_app/feature/views/group-chat/add_participants_view.dart';
import 'package:flutter/material.dart';

import '../../../model/profile.dart';
import '../../../view-models/group-chat/add_participants_view_model.dart';

mixin AddParticipantsViewMixin on State<AddParticipantsView> {


  final addParticipantsViewModel = AddParticipantsViewModel();

  List<Profile> newGroupMembers = [];

  bool isSelected(Profile clickedProfile) {
    bool isSelected = false;

    for (var profile in newGroupMembers) {
      if (profile.toJson()['email'] == clickedProfile.toJson()['email']) {
        isSelected = true;
      }
    }
    return isSelected;
  }

  void removeSelectedProfile(Profile clickedProfile) {
    for (int i = 0; i < newGroupMembers.length; i++) {
      if (clickedProfile.toJson()['email'] ==
          newGroupMembers[i].toJson()['email']) {
        newGroupMembers.removeAt(i);
      }
    }
  }

  void onTileClicked(Profile profile) {
    setState(() {
      if (isSelected(profile)) {
        removeSelectedProfile(profile);
      } else {
        newGroupMembers.add(profile);
      }
    });
  }



}