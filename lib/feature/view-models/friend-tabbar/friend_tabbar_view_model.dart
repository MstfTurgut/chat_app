import 'package:chat_app/product/db/database.dart';
import 'package:flutter/material.dart';

import '../../model/profile.dart';

class FriendTabbarViewModel extends ChangeNotifier {

  final _database = Database();

  Stream<List<Profile>> getRequestProfilesStream() {

    var docListStream =
        _database.getRequestsQuerySnapshotStream().map((querySnap) => querySnap.docs);

    var profileListStream = docListStream.map((docList) => docList
        .map((doc) => Profile.fromJson(doc.data() as Map<String, dynamic>))
        .toList());

    return profileListStream;
  }
  
}
