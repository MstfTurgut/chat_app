import 'dart:io';

import 'package:chat_app/feature/view-models/group-chat/group_chat_view_model.dart';
import 'package:chat_app/feature/view-models/settings/profile_settings_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../product/db/database.dart';
import '../../model/group.dart';
import '../../model/message.dart';
import '../../model/profile.dart';

class GroupInfoViewModel {
  final _database = Database();
  final _firebaseAuth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  final _groupChatViewModel = GroupChatViewModel();

  String basicGroupPhotoUrl =
      'https://firebasestorage.googleapis.com/v0/b/chat-app-demo-7ebb6.appspot.com/o/groupProfilePhotos%2Fgroup_default.png?alt=media&token=d8255e17-cb5a-44ec-bfbc-8258d00574db';

  final _profileSettingsViewModel = ProfileSettingsViewModel();

  Future<String> putGroupImageToStorage(File file) async {
    TaskSnapshot taskSnapshot = await _storage
        .ref()
        .child('groupProfilePhotos')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg')
        .putFile(file);

    String uploadedImageUrl = await taskSnapshot.ref.getDownloadURL();

    return uploadedImageUrl;
  }

  Future<void> changeCurrentGroupPhoto(String groupId, String photoUrl) async {
    //changing current profile photo from database

    await _database.updateGroup({'groupPhotoUrl': photoUrl}, groupId);

    // sending notice message

    Message noticeMessage = Message(
        senderEmail: _firebaseAuth.currentUser!.email!,
        receiverId: groupId,
        timestamp: Timestamp.now(),
        senderId: _firebaseAuth.currentUser!.uid,
        text: '${_firebaseAuth.currentUser!.email!}  changed  group  photo ',
        isNoticeMessage: true);

    await _database.sendMessage(
        chatRoomId: groupId, messageJson: noticeMessage.toJson());
  }

  Future<void> changeGroupName(String newGroupName, String groupId) async {
    await _database.updateGroup({'groupName': newGroupName}, groupId);

    // sending notice message

    Message noticeMessage = Message(
        senderEmail: _firebaseAuth.currentUser!.email!,
        receiverId: groupId,
        timestamp: Timestamp.now(),
        senderId: _firebaseAuth.currentUser!.uid,
        text: '${_firebaseAuth.currentUser!.email!}  changed  group  name',
        isNoticeMessage: true);

    await _database.sendMessage(
        chatRoomId: groupId, messageJson: noticeMessage.toJson());
  }

  Future<void> addProfile(String uid, String groupId) async {
    var targetProfile = Profile.fromJson(await _database.getProfileMap(uid));

    await _database.addMemberToGroup(
        groupId: groupId, profileMap: targetProfile.toJson());

    List<Group> groupList = [];

    for (var group in targetProfile.groups) {
      groupList.add(group);
    }

    var groupDoc = await _database.getGroupMap(groupId);

    Group group = Group.fromJson(groupDoc.data() as Map<String, dynamic>);

    groupList.add(group);

    var updatedGroupListMap = groupList.map((group) => group.toJson()).toList();

    await _database
        .updateProfile(updateMap: {'groups': updatedGroupListMap}, uid: uid);

    // sending notice message

    Message noticeMessage = Message(
        senderEmail: _firebaseAuth.currentUser!.email!,
        receiverId: groupId,
        timestamp: Timestamp.now(),
        senderId: _firebaseAuth.currentUser!.uid,
        text:
            '${_firebaseAuth.currentUser!.email!}  added  ${targetProfile.email} ',
        isNoticeMessage: true);

    await _database.sendMessage(
        chatRoomId: groupId, messageJson: noticeMessage.toJson());
  }

  Future<void> removeProfile(String groupId, String uid) async {
    await _database.removeMember(groupId, uid);

    /// if removed profile is also a group admin then you have to update groupIdList in group too

    var groupQuery = await _database.getGroupMap(groupId);

    var groupMap = groupQuery.data() as Map<String, dynamic>;

    Group targetGroup = Group.fromJson(groupMap);

    if (_groupChatViewModel.isAdmin(targetGroup.adminIdList, uid)) {
      List<String> updatedGroupIdList = [];

      for (var id in targetGroup.adminIdList) {
        updatedGroupIdList.add(id);
      }

      for (int i = 0; i < updatedGroupIdList.length; i++) {
        if (updatedGroupIdList[i] == uid) {
          updatedGroupIdList.removeAt(i);
        }
      }

      await _database.updateGroup({'adminIdList': updatedGroupIdList}, groupId);
    }

    ////

    var targetProfile = Profile.fromJson(await _database.getProfileMap(uid));

    List<Group> groupList = [];

    for (var group in targetProfile.groups) {
      groupList.add(group);
    }

    for (int i = 0; i < groupList.length; i++) {
      var group = groupList[i];
      if (group.groupId == groupId) {
        groupList.removeAt(i);
      }
    }

    var updatedGroupListMap = groupList.map((group) => group.toJson()).toList();

    await _database
        .updateProfile(updateMap: {'groups': updatedGroupListMap}, uid: uid);

    // sending notice message

    Message noticeMessage = Message(
        senderEmail: _firebaseAuth.currentUser!.email!,
        receiverId: groupId,
        timestamp: Timestamp.now(),
        senderId: _firebaseAuth.currentUser!.uid,
        text:
            '${_firebaseAuth.currentUser!.email!}  removed  ${targetProfile.email} ',
        isNoticeMessage: true);

    await _database.sendMessage(
        chatRoomId: groupId, messageJson: noticeMessage.toJson());
  }

  Future<void> makeAdmin(
      String profileEmail, String uid, String groupId) async {
    var groupQuery = await _database.getGroupMap(groupId);

    var groupMap = groupQuery.data() as Map<String, dynamic>;

    List<String> updatedGroupIdList = [];

    for (var id in groupMap['adminIdList']) {
      updatedGroupIdList.add(id);
    }

    updatedGroupIdList.add(uid);

    await _database.updateGroup({'adminIdList': updatedGroupIdList}, groupId);

    // sending notice message

    Message noticeMessage = Message(
        senderEmail: _firebaseAuth.currentUser!.email!,
        receiverId: groupId,
        timestamp: Timestamp.now(),
        senderId: _firebaseAuth.currentUser!.uid,
        text: '$profileEmail  is  now  an  admin !',
        isNoticeMessage: true);

    await _database.sendMessage(
        chatRoomId: groupId, messageJson: noticeMessage.toJson());
  }

  Future<String> getCurrentGroupPhotoUrl(String groupId) async {
    var groupMapDoc = await _database.getGroupMap(groupId);

    var groupMap = groupMapDoc.data() as Map<String, dynamic>;

    return groupMap['groupPhotoUrl'];
  }

  Future<File?> getImageAndCrop(bool fromCamera, String groupId) async {
    final picker = ImagePicker();

    final pickedImage = await picker.pickImage(
        source: (fromCamera) ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 50);

    CroppedFile? croppedFile;

    if (pickedImage != null) {
      croppedFile = await ImageCropper().cropImage(
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        sourcePath: pickedImage.path,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Crop Image',
              toolbarColor: Colors.amber,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true),
        ],
      );
    }

    if (croppedFile != null) {
      var currentGroupPhotoUrl = await getCurrentGroupPhotoUrl(groupId);

      if (currentGroupPhotoUrl != basicGroupPhotoUrl) {
        await _profileSettingsViewModel
            .deleteOldProfilePhotoFromStorage(currentGroupPhotoUrl);
      }

      String newGroupPhotoUrl =
          await putGroupImageToStorage(File(croppedFile.path));

      await changeCurrentGroupPhoto(groupId, newGroupPhotoUrl);

      return File(croppedFile.path);
    } else {
      return null;
    }
  }
}
