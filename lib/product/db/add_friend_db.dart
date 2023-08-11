import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

mixin AddFriendDatabase {
  final _firebaseFirestore = FirebaseFirestore.instance;
  final _firebaseAuth = FirebaseAuth.instance;

  Future<void> addFriend(
      {required Map<String, dynamic> profileMap, required String uid}) async {
    await _firebaseFirestore
        .collection('profiles')
        .doc(uid)
        .collection('friends')
        .doc(profileMap['uid'])
        .set(profileMap);
  }

  Future<void> removeFriend({required String uid}) async {
    await _firebaseFirestore
        .collection('profiles')
        .doc(_firebaseAuth.currentUser!.uid)
        .collection('friends')
        .doc(uid)
        .delete();

    await _firebaseFirestore
        .collection('profiles')
        .doc(uid)
        .collection('friends')
        .doc(_firebaseAuth.currentUser!.uid)
        .delete();
  }

  Future<void> addRequest(
      {required Map<String, dynamic> profileMap,
      required String receiverId}) async {
    await _firebaseFirestore
        .collection('profiles')
        .doc(receiverId)
        .collection('friendRequests')
        .doc(profileMap['uid'])
        .set(profileMap);
  }

  Future<void> deleteRequest({required String requestId}) async {
    await _firebaseFirestore
        .collection('profiles')
        .doc(_firebaseAuth.currentUser!.uid)
        .collection('friendRequests')
        .doc(requestId)
        .delete();
  }

  Future<QuerySnapshot> getRequestsQuerySnapshot(String uid) async {
    return await _firebaseFirestore
        .collection('profiles')
        .doc(uid)
        .collection('friendRequests')
        .get();
  }

  Stream<QuerySnapshot> getRequestsQuerySnapshotStream() {
    return _firebaseFirestore
        .collection('profiles')
        .doc(_firebaseAuth.currentUser!.uid)
        .collection('friendRequests')
        .snapshots();
  }
}
