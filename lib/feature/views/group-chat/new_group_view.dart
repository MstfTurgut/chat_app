import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/feature/views/group-chat/mixin/new_group_view_mixin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../product/error_dialog.dart';
import '../../../product/services/auth_service.dart';
import '../../model/profile.dart';

class NewGroupView extends StatefulWidget {
  const NewGroupView({required this.friendList, super.key});

  final List<Profile> friendList;

  @override
  State<NewGroupView> createState() => _NewGroupViewState();
}

class _NewGroupViewState extends State<NewGroupView> with NewGroupViewMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Group'),
        actions: [
          (newGroupMembers.isNotEmpty)
              ? IconButton(
                  onPressed: () async {
                    await _showNewGroupDialog(newGroupMembers);
                  },
                  icon: const Icon(Icons.check))
              : const SizedBox.shrink()
        ],
      ),
      body: ListView.builder(
        itemCount: widget.friendList.length,
        itemBuilder: (context, index) {
          return _buildProfileListItem(widget.friendList[index]);
        },
      ),
    );
  }

  Widget _buildProfileListItem(Profile profile) {
    return Column(
      children: [
        ListTile(
          tileColor: isSelected(profile) ? Colors.green.shade100 : Colors.white,
          contentPadding: const EdgeInsets.all(15),
          title: Text(
            profile.email,
            style: const TextStyle(fontSize: 18),
          ),
          leading: SizedBox(
            height: 50,
            width: 50,
            child: CachedNetworkImage(
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      fit: BoxFit.contain,
                      imageUrl: profile.profilePhotoUrl,
                      imageBuilder: (context, imageProvider) {
                        return CircleAvatar(
                          backgroundImage: imageProvider,
                        );
                      },
                    ),
          ),
          onTap: () {
            onTileClicked(profile);
          },
        ),
        const Divider(),
      ],
    );
  }

  Future<void> _showNewGroupDialog(List<Profile> groupMembers) async {
    bool isClicked = false;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('New Group!')),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Group Name'),
                Form(
                  key: formStateKey,
                  child: TextFormField(
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field cannot be blank';
                      } else {
                        return null;
                      }
                    },
                    controller: groupNameController,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel')),
            TextButton(
              onPressed: (!isClicked)
                  ? () async {
                      if (formStateKey.currentState!.validate()) {
                        isClicked = true;
                        if (!mounted) return;
                        Navigator.pop(context);
                        Navigator.pop(context);
                        
                        Profile currentProfile = await context
                            .read<AuthService>()
                            .getCurrentProfile();

                        try {
                          await newGroupViewModel.newGroup(
                              currentProfile: currentProfile,
                              members: groupMembers,
                              groupName: groupNameController.text);
                        } catch (e) {
                          if (!mounted) return;
                          await showErrorDialog(Text('$e'), context);
                        }

                      }
                    }
                  : null,
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }
}
