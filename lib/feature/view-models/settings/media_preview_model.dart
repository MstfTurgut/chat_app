import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class ImagePreviewModel {
  final _storage = FirebaseStorage.instance;

  Future<File?> cropImage({required File file}) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      sourcePath: file.path,
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.amber,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true),
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    } else {
      return null;
    }
  }

  Future<String> putImageToStorage(File file) async {
    TaskSnapshot taskSnapshot = await _storage
        .ref()
        .child('photos')
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg')
        .putFile(file);

    String uploadedImageUrl = await taskSnapshot.ref.getDownloadURL();

    return uploadedImageUrl;
  }

}
