


import 'package:flutter/material.dart';

import '../../../model/profile.dart';
import '../../../view-models/group-chat/new_group_view_model.dart';
import '../new_group_view.dart';

mixin NewGroupViewMixin on State<NewGroupView> {


  final newGroupViewModel = NewGroupViewModel();

  final formStateKey = GlobalKey<FormState>();
  final groupNameController = TextEditingController();

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