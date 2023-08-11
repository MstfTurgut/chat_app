

import 'package:chat_app/feature/views/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../product/services/auth_service.dart';
import '../../../model/profile.dart';
import '../../../view-models/home/friends_list_view_model.dart';
import '../../friend-tabbar/friend_tabbar_view.dart';
import '../../group-chat/new_group_view.dart';
import '../../settings/profile_settings_view.dart';

mixin HomeViewMixin on State<HomeView> {
  
  void signOut() async {
    await context.read<AuthService>().signOut();
  }

  void goToFriendTabbar() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => FriendTabbarView()));
  }

  Future<void> goToSettings() async {
    Profile currentProfile =
        await context.read<AuthService>().getCurrentProfile();

    if (!mounted) return;
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileSettingsView(
            currentProfile: currentProfile,
          ),
        ));
  }

  Future<void> newGroup() async{
    var friendsListViewModel = FriendsListViewModel();
    List<Profile> friendList = await friendsListViewModel.getFriendsProfiles();

    if(!mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (context) => NewGroupView(friendList: friendList)));
  }


}