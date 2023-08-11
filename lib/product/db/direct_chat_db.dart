
import 'package:cloud_firestore/cloud_firestore.dart';

mixin DirectChatDatabase {


  final _firebaseFirestore = FirebaseFirestore.instance;


    Future<void> sendMessage(
      {required String chatRoomId,
      required Map<String, dynamic> messageJson}) async {
    //construct chat room id from current user id and receiver user id (sorted to ensure uniqueness)

    //add a new message to database
    _firebaseFirestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageJson['timestamp'])
        .set(messageJson);
  }

  Future<void> deleteMessage(String messageId, String chatRoomId) async {
    await _firebaseFirestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  Stream<QuerySnapshot> getMessagesStream(String chatRoomId) {
    // construct chat room id from senderId and receiverId to access chat room

    return _firebaseFirestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }





}