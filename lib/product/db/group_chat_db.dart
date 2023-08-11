import 'package:cloud_firestore/cloud_firestore.dart';
mixin GroupDatabase {


  final _firebaseFirestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot> getGroupMap(String groupId) async {
    return await _firebaseFirestore.collection('chat_rooms').doc(groupId).get();
  }

  

  Stream<DocumentSnapshot> getGroupDocStream(String groupId) {
    return _firebaseFirestore.collection('chat_rooms').doc(groupId).snapshots();
  }

  Stream<QuerySnapshot> getGroupChatMessagesStream(String groupChatId) {
    return _firebaseFirestore
        .collection('chat_rooms')
        .doc(groupChatId)
        .collection('messages')
        .snapshots();
  }

  Future<void> addNewGroup({required Map<String, dynamic> group}) async {
    await _firebaseFirestore
        .collection('chat_rooms')
        .doc(group['groupId'])
        .set(group);
  }

  Future<void> addMemberToGroup(
      {required String groupId,
      required Map<String, dynamic> profileMap}) async {
    await _firebaseFirestore
        .collection('chat_rooms')
        .doc(groupId)
        .collection('members')
        .doc(profileMap['uid'])
        .set(profileMap);
  }

  Future<void> removeMember(String groupId, String uid) async {
    await _firebaseFirestore
        .collection('chat_rooms')
        .doc(groupId)
        .collection('members')
        .doc(uid)
        .delete();
  }

  Future<QuerySnapshot> getMemberList(String groupId) async {
    var membersQuery = await _firebaseFirestore
        .collection('chat_rooms')
        .doc(groupId)
        .collection('members')
        .get();
    
    return membersQuery;
  }




}