import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../model/profile.dart';
import 'mixin/profile_settings_view_mixin.dart';

class ProfileSettingsView extends StatefulWidget {
  const ProfileSettingsView({super.key, required this.currentProfile});

  final Profile currentProfile;

  @override
  State<ProfileSettingsView> createState() => _ProfileSettingsViewState();
}

class _ProfileSettingsViewState extends State<ProfileSettingsView>
    with ProfileSettingsViewMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          (image != null)
              ? IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: changePhotoAndExit,
                )
              : const SizedBox(
                  width: 0,
                ),
        ],
        title: const Text('Profile Settings'),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          Stack(children: [
            SizedBox(
                height: 130,
                width: 130,
                child: (image != null)
                    ? CircleAvatar(backgroundImage: FileImage(image!))
                    : CachedNetworkImage(
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        fit: BoxFit.contain,
                        imageUrl: widget.currentProfile.profilePhotoUrl,
                        imageBuilder: (context, imageProvider) {
                          return CircleAvatar(
                            backgroundImage: imageProvider,
                          );
                        },
                      )),
            Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () async {
                    bool? fromCamera;

                    fromCamera = await camOrGalleryBottomSheet(context);

                    if (!mounted) return;
                    if (fromCamera != null) {
                      image = await profileSettingsViewModel
                          .getImageAndCrop(fromCamera);

                      setState(() {});
                    }
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(20)),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                    ),
                  ),
                ))
          ]),
          const SizedBox(
            height: 50,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.email),
            title: Text(
              widget.currentProfile.email,
              style: const TextStyle(fontSize: 17),
            ),
            subtitle: const Text('Email'),
          )
        ],
      ),
    );
  }

  Future<bool?> camOrGalleryBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadiusDirectional.only(
              topStart: Radius.circular(10), topEnd: Radius.circular(10))),
      context: context,
      builder: (context) {
        return SizedBox(
          height: 170,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text(
                  'Choose Image From',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              SizedBox(
                                  height: 70,
                                  width: 70,
                                  child: Image.asset('assets/gallery.png')),
                              const Text('Gallery'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 70,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context, true),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              SizedBox(
                                  height: 70,
                                  width: 70,
                                  child: Image.asset('assets/camera.png')),
                              const Text('Camera'),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
