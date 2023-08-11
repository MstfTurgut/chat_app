import 'package:chat_app/feature/model/profile.dart';
import 'package:chat_app/product/db/add_friend_db.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../feature/model/group.dart';
import 'direct_chat_db.dart';
import 'group_chat_db.dart';

class Database with GroupDatabase,DirectChatDatabase,AddFriendDatabase{

  final _firebaseFirestore = FirebaseFirestore.instance;
  final _firebaseAuth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getProfilesQuerySnapshotStream() {
    return _firebaseFirestore.collection('profiles').snapshots();
  }

  Future<void> addAndUpdateProfile(
      {required Map<String, dynamic> profileMap}) async {
    await _firebaseFirestore
        .collection('profiles')
        .doc(profileMap['uid'])
        .set(profileMap);
  }


  Future<Map<String, dynamic>> getProfileMap(String uid) async {
    var doc = await _firebaseFirestore.collection('profiles').doc(uid).get();

    return doc.data() as Map<String, dynamic>;
  }

  Stream<Map<String, dynamic>> getProfileStream(String uid) {
    var mapDocStream =
        _firebaseFirestore.collection('profiles').doc(uid).snapshots();

    return mapDocStream.map((doc) => doc.data() as Map<String, dynamic>);
  }

  Stream<QuerySnapshot> getFriendsQuerySnapshotStream() {
    return _firebaseFirestore
        .collection('profiles')
        .doc(_firebaseAuth.currentUser!.uid)
        .collection('friends')
        .snapshots();
  }

  Future<QuerySnapshot> getFriendsQuerySnapshot() {
    return _firebaseFirestore
        .collection('profiles')
        .doc(_firebaseAuth.currentUser!.uid)
        .collection('friends')
        .get();
  }


  Future<void> updateProfile({required Map<String, dynamic> updateMap,required String uid}) async {
    await _firebaseFirestore.collection('profiles').doc(uid).update(updateMap);

    var friendsUidList = await _firebaseFirestore
        .collection('profiles')
        .doc(uid)
        .collection('friends')
        .get()
        .then((querySnap) =>
            querySnap.docs.map((doc) => (doc.data())['uid']).toList());

    for (var friendsUid in friendsUidList) {
      await _firebaseFirestore
          .collection('profiles')
          .doc(friendsUid)
          .collection('friends')
          .doc(uid)
          .update(updateMap);
    }

    var profileMap = await _firebaseFirestore
        .collection('profiles')
        .doc(uid)
        .get()
        .then((value) => value.data() as Map<String, dynamic>);

    var profileGroupList = Profile.fromJson(profileMap).groups;

    for (var group in profileGroupList) {
      await _firebaseFirestore
          .collection('chat_rooms')
          .doc(group.groupId)
          .collection('members')
          .doc(uid)
          .update(updateMap);
    }
  }


  Future<void> updateGroup(
      Map<String, dynamic> updateMap, String groupId) async {
    await _firebaseFirestore
        .collection('chat_rooms')
        .doc(groupId)
        .update(updateMap);

    var membersQuery = await _firebaseFirestore
        .collection('chat_rooms')
        .doc(groupId)
        .collection('members')
        .get();

    var docList = membersQuery.docs;

    var membersUidList =
        docList.map((doc) => (doc.data())['uid'] as String).toList();

    for (var uid in membersUidList) {
      var doc = await _firebaseFirestore.collection('profiles').doc(uid).get();

      var targetProfile = Profile.fromJson(doc.data() as Map<String, dynamic>);

      List<Group> updatedGroupList = [];

      for (var group in targetProfile.groups) {
        updatedGroupList.add(group);
      }

      for (int i = 0; i < updatedGroupList.length; i++) {
        var group = updatedGroupList[i];
        if (group.groupId == groupId) {
          var groupMap = group.toJson();

          groupMap.update(updateMap.keys.toList()[0],
              (value) => updateMap.values.toList()[0]);

          updatedGroupList[i] = Group.fromJson(groupMap);
        }
      }

      var updatedGroupListMap = updatedGroupList
          .map(
            (e) => e.toJson(),
          )
          .toList();

      updateProfile(updateMap:{'groups': updatedGroupListMap},uid: uid);
    }
  }

  

  

}
