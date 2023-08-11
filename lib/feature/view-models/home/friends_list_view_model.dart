import 'package:flutter/material.dart';

import '../../model/profile.dart';
import '../../../product/db/database.dart';

class FriendsListViewModel extends ChangeNotifier {
  final _database = Database();


Stream<List<Profile>> getFriendsProfilesStream() {

  var docListStream = _database.getFriendsQuerySnapshotStream().map((querySnap) => querySnap.docs);

  var mapListStream = docListStream.map((docList) => docList.map((doc) => doc.data() as Map<String,dynamic>).toList());

  return mapListStream.map((mapList) => mapList.map((map) => Profile.fromJson(map)).toList());

}

Future<List<Profile>> getFriendsProfiles() async{

  var query = await _database.getFriendsQuerySnapshot();

  var docList = query.docs;

  var mapList = docList.map((doc) => doc.data() as Map<String,dynamic>).toList();

  return mapList.map((map) => Profile.fromJson(map)).toList();

}

Future<void> unfriend({required String friendUid}) async{
  await _database.removeFriend(uid: friendUid);
}

}
