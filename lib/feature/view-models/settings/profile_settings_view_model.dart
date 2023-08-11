import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../model/profile.dart';
import '../../../product/db/database.dart';


class ProfileSettingsViewModel {


  final _database = Database();
  final _storage = FirebaseStorage.instance;


  Future<File?> getImageAndCrop(bool fromCamera) async {

    final picker = ImagePicker();

    final pickedImage = await picker.pickImage(
        source: (fromCamera)?ImageSource.camera:ImageSource.gallery , imageQuality: 50);

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
          lockAspectRatio: true
          ),
    ],
  );
}

    
      if (croppedFile != null) {
        return File(croppedFile.path);
      } else {
        return null;
      }

  }

  Future<String> putImageToStorage(File file) async {

    TaskSnapshot taskSnapshot = await _storage
        .ref()
        .child('profilePhotos')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg')
        .putFile(file);

    String uploadedImageUrl = await taskSnapshot.ref.getDownloadURL();

    return uploadedImageUrl;

  }


  Future<void> changeCurrentProfilePhoto(Profile currentProfile , String photoUrl) async{

    //changing current profile photo from database
    await _database.updateProfile(updateMap:{'profilePhotoUrl' : photoUrl},uid: currentProfile.uid);

  }

  Future<void> deleteOldProfilePhotoFromStorage(String photoUrl) async{
    await _storage.refFromURL(photoUrl).delete();

  }






}