import 'package:chat_app/product/db/database.dart';
import 'package:flutter/material.dart';

import '../../model/profile.dart';

class FriendRequestsViewModel extends ChangeNotifier {
  final _database = Database();

  Future<void> acceptFriendRequest(
      Profile currentProfile, Profile senderProfile) async {

    // senderProfile is should also be pulled from database because the profile info can change
    // before the currentProfile accept request

    var senderProfileMapFromDatabase =
        await _database.getProfileMap(senderProfile.uid);

    // add current profile to senders friends list

    _database.addFriend(profileMap: currentProfile.toJson(), uid: senderProfile.uid);

    // add sender profile to currents friends list

    _database.addFriend(profileMap: senderProfileMapFromDatabase, uid: currentProfile.uid);

    //  delete request 

    _database.deleteRequest(requestId: senderProfile.uid);

  }



  Future<void> rejectFriendRequest(Profile senderProfile) async {

    _database.deleteRequest(requestId: senderProfile.uid);

  }
}
