import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/feature/views/group-chat/add_participants_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../model/group.dart';
import '../../model/profile.dart';
import 'mixin/group_info_view_mixin.dart';

class GroupInfoView extends StatefulWidget {
  const GroupInfoView(
      {super.key,
      required this.group,
      required this.isCurrentProfileAdmin,
      required this.groupMembers});

  final List<Profile> groupMembers;
  final Group group;
  final bool isCurrentProfileAdmin;

  @override
  State<GroupInfoView> createState() => _GroupInfoViewState();
}

class _GroupInfoViewState extends State<GroupInfoView> with GroupInfoViewMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: (widget.isCurrentProfileAdmin)
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddParticipantsView(
                            groupMembers: widget.groupMembers,
                            groupId: widget.group.groupId),
                      ));
                },
                child: const Icon(Icons.person_add),
              )
            : null,
        appBar: AppBar(
          title: const Text('Group Info'),
        ),
        body: ListView.builder(
          itemCount: widget.groupMembers.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return groupInfoColumn(context);
            } else {
              bool isAdmin = groupChatViewModel.isAdmin(
                  widget.group.adminIdList, widget.groupMembers[index - 1].uid);

              return Column(
                children: [
                  Slidable(
                    startActionPane: (widget.isCurrentProfileAdmin)
                        ? ActionPane(
                            extentRatio: (isAdmin) ? 0.25 : 0.5,
                            motion: const ScrollMotion(),
                            children: [
                                (!isAdmin)
                                    ? SlidableAction(
                                        backgroundColor: Colors.lightBlue,
                                        label: 'Make Admin',
                                        icon: Icons.manage_accounts,
                                        onPressed: (_) async {
                                          bool? isDone =
                                              await showMyMakeAdminConfirmDialog(
                                                  widget
                                                      .groupMembers[index - 1],
                                                  widget.group.groupId);

                                          if (isDone == true) {
                                            if (!mounted) return;
                                            Navigator.pop(context);
                                          }
                                        })
                                    : const SizedBox.shrink(),
                                SlidableAction(
                                    backgroundColor: Colors.redAccent,
                                    label: 'Remove',
                                    icon: Icons.remove,
                                    onPressed: (_) async {
                                      bool? isDone =
                                          await showMyRemoveProfileConfirmDialog(
                                              widget.groupMembers[index - 1],
                                              widget.group.groupId);

                                      if (isDone == true) {
                                        if (!mounted) return;
                                        Navigator.pop(context);
                                      }
                                    }),
                              ])
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(
                          widget.groupMembers[index - 1].email,
                        ),
                        leading: SizedBox(
                          height: 45,
                          width: 45,
                          child: CachedNetworkImage(
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      fit: BoxFit.contain,
                      imageUrl: widget.groupMembers[index-1].profilePhotoUrl,
                      imageBuilder: (context, imageProvider) {
                        return CircleAvatar(
                          backgroundImage: imageProvider,
                        );
                      },
                    )
                        ),
                        trailing: (groupChatViewModel.isAdmin(
                                widget.group.adminIdList,
                                widget.groupMembers[index - 1].uid))
                            ? const Icon(
                                Icons.manage_accounts,
                                color: Colors.greenAccent,
                              )
                            : null,
                      ),
                    ),
                  ),
                  const Divider(
                    indent: 20,
                    endIndent: 20,
                  ),
                ],
              );
            }
          },
        ));
  }

  Column groupInfoColumn(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 50,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  (newGroupName == null)
                      ? widget.group.groupName
                      : newGroupName!,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            (widget.isCurrentProfileAdmin)
                ? Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: IconButton(
                        onPressed: changeGroupName,
                        icon: const Icon(
                          Icons.edit,
                          color: Colors.grey,
                        )),
                  )
                : const SizedBox.shrink(),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Stack(children: [
          SizedBox(
              height: 130,
              width: 130,
              child: (image != null)?CircleAvatar(
                backgroundImage: FileImage(image!),
              ):CachedNetworkImage(
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      fit: BoxFit.contain,
                      imageUrl: widget.group.groupPhotoUrl,
                      imageBuilder: (context, imageProvider) {
                        return CircleAvatar(
                          backgroundImage: imageProvider,
                        );
                      },
                    ) ),
          (widget.isCurrentProfileAdmin)
              ? Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: changeGroupPhoto,
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
              : const SizedBox.shrink(),
        ]),
        const SizedBox(
          height: 50,
        ),
        const Text(
          'Members',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }

  void changeGroupPhoto() async {
    bool? fromCamera;

    fromCamera = await camOrGalleryBottomSheet(context);

    if (!mounted) return;
    if (fromCamera != null) {
      image = await groupInfoViewModel.getImageAndCrop(fromCamera , widget.group.groupId);

      setState(() {});
    }
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
