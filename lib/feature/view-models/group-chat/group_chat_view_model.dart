import 'dart:io';
import 'package:chat_app/feature/model/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../product/db/database.dart';
import '../../model/group.dart';
import '../../model/message.dart';

class GroupChatViewModel{

  final _firebaseAuth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  final _database = Database();


  Stream<Group> getGroupStream(String groupId) {
    
    var docStream = _database.getGroupDocStream(groupId);

    return docStream.map((doc) => Group.fromJson(doc.data() as Map<String,dynamic>));

  }





  Future<void> sendMessage({required String chatRoomId, String? text , String? imageUrl}) async {
    // get current user info
    final currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final currentUserId = _firebaseAuth.currentUser!.uid;
    final timestamp = Timestamp.now();

    //create a new message
    Message newMessage = Message(
        senderEmail: currentUserEmail,
        receiverId: chatRoomId,
        text: text,
        imageUrl: imageUrl,
        timestamp: timestamp,
        senderId: currentUserId);

    Map<String,dynamic> messageJson = newMessage.toJson();

    _database.sendMessage(chatRoomId: chatRoomId,messageJson: messageJson);
  }


  bool isAdmin(List<String> idList, String uid) {

    bool isAdmin = false;

    if(idList.contains(uid)) {
      isAdmin = true;
    }

    return isAdmin;

  }


  Future<void> exitGroup(String groupId) async{

    var currentProfile = Profile.fromJson(await _database.getProfileMap(_firebaseAuth.currentUser!.uid));

    List<Group> groupList = [];

    for (var group in currentProfile.groups) {
      groupList.add(group);
    }

    for (int i = 0; i < groupList.length; i++) {
      var group = groupList[i];
      if(group.groupId == groupId) {
        groupList.removeAt(i);
      }
    }

    var updatedGroupListMap = groupList.map((group) => group.toJson()).toList();

    await _database.updateProfile(updateMap: {'groups' : updatedGroupListMap},uid: currentProfile.uid);

    await _database.removeMember(groupId, _firebaseAuth.currentUser!.uid);

    // if profile a group admin then you have to update the groupIdList too

    var groupQuery = await _database.getGroupMap(groupId);

    var groupMap = groupQuery.data() as Map<String,dynamic>;

    Group targetGroup = Group.fromJson(groupMap);

    if(isAdmin(targetGroup.adminIdList, currentProfile.uid)) {

      List<String> updatedGroupIdList = [];

      for (var id in targetGroup.adminIdList) {
        updatedGroupIdList.add(id);
      }

      for (int i = 0; i < updatedGroupIdList.length; i++) {
    
        if(updatedGroupIdList[i] == currentProfile.uid) {
          updatedGroupIdList.removeAt(i);
        }

      }

    // if there is no admin left after profile exits group you have to choose another admin

      if(updatedGroupIdList.isEmpty) {
        List<Profile> memberList = await getGroupMembers(groupId);
        updatedGroupIdList.add(memberList[0].uid);
      }

      await _database.updateGroup({'adminIdList' : updatedGroupIdList}, groupId);



    }

    // sending notice message

    Message noticeMessage = Message(
      senderEmail: currentProfile.email,
      receiverId: groupId, 
      timestamp: Timestamp.now(), 
      senderId: currentProfile.uid,
      text: '${currentProfile.email}  left  the  group',
      isNoticeMessage: true);

    await _database.sendMessage(chatRoomId: groupId, messageJson: noticeMessage.toJson());
    
  }


  Future<List<Profile>> getGroupMembers(String groupId) async{

    var membersQuery = await _database.getMemberList(groupId);

    var docList = membersQuery.docs;

    var memberList = docList.map((doc) => Profile.fromJson(doc.data() as Map<String,dynamic>)).toList();

    return memberList;

  } 



  Stream<List<Message>> getMessageListStream({required String chatRoomId}) {

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



  Future<void> deleteMessageFromGroup( Message message , String groupId) async{

    var messageJson = message.toJson();

    await _database.deleteMessage(messageJson['timestamp'], groupId);

    if(message.imageUrl != null) {
      await _storage.refFromURL(message.imageUrl!).delete();
    }

  }




}