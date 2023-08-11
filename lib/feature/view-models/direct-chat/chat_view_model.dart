import 'dart:io';

import 'package:chat_app/feature/model/message.dart';
import 'package:chat_app/product/db/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';

import '../../model/profile.dart';

class ChatViewModel extends ChangeNotifier {
  final _firebaseAuth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  final _database = Database();

  // SEND MESSAGE

  Future<void> sendMessage({required Profile receiverProfile, String? text , String? imageUrl}) async {
    // get current user info
    final currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final currentUserId = _firebaseAuth.currentUser!.uid;
    final timestamp = Timestamp.now();

    //create a new message
    Message newMessage = Message(
        senderEmail: currentUserEmail,
        receiverId: receiverProfile.uid,
        text: text,
        imageUrl: imageUrl,
        timestamp: timestamp,
        senderId: currentUserId);

    Map<String,dynamic> messageJson = newMessage.toJson();


    List<String> ids = [messageJson['senderId'], messageJson['receiverId']];
    ids.sort();
    String chatRoomId = ids.join('_');

    _database.sendMessage(chatRoomId: chatRoomId,messageJson: messageJson);
  }

  // GET MESSAGE

  Stream<List<Message>> getMessageListStream(
      {required Profile senderProfile,required Profile receiverProfile}) {

    List<String> ids = [senderProfile.uid, receiverProfile.uid];
    ids.sort();
    String chatRoomId = ids.join('_');
        
    var messageDocumentListStream = _database
        .getMessagesStream(chatRoomId)
        .map((querySnapshot) => querySnapshot.docs);

    var messageListStream = messageDocumentListStream.map((documentList) => documentList
        .map((doc) => Message.fromJson(doc.data() as Map<String, dynamic>))
        .toList());

    return messageListStream;
  }

  Future<File?> getImage() async{
    final picker = ImagePicker();

    final pickedImage = await picker.pickImage(source: ImageSource.camera,imageQuality: 50);

    if(pickedImage != null) {
      return File(pickedImage.path);
    } else {
      return null;
    }

  }

  Future<void> deleteMessageFromChat( {required Message message} ) async{

    var messageJson = message.toJson();

    List<String> ids = [messageJson['senderId'], messageJson['receiverId']];
    ids.sort();
    String chatRoomId = ids.join('_');

    await _database.deleteMessage(messageJson['timestamp'], chatRoomId);

    if(message.imageUrl != null) {
      await _storage.refFromURL(message.imageUrl!).delete();
    }
  
  }




}


