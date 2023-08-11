import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/feature/views/group-chat/mixin/add_participants_view_mixin.dart';
import 'package:flutter/material.dart';
import '../../../product/error_dialog.dart';
import '../../model/profile.dart';

class AddParticipantsView extends StatefulWidget {
  final List<Profile> groupMembers;
  final String groupId;

  const AddParticipantsView(
      {super.key, required this.groupMembers, required this.groupId});

  @override
  State<AddParticipantsView> createState() => _AddParticipantsViewState();
}

class _AddParticipantsViewState extends State<AddParticipantsView>
    with AddParticipantsViewMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Participants'),
          actions: [
            (newGroupMembers.isNotEmpty)
                ? IconButton(
                    onPressed: () async {
                      if (!mounted) return;
                      Navigator.pop(context);
                      Navigator.pop(context);
                      try {
                        await addParticipantsViewModel.addParticipants(
                            newGroupMembers, widget.groupId);
                      }  catch (e) {
                        await showErrorDialog(Text('$e'), context);
                      }
                    },
                    icon: const Icon(Icons.check))
                : const SizedBox.shrink()
          ],
        ),
        body: FutureBuilder(
          future: addParticipantsViewModel.friendsNotAMember(
              widget.groupId, widget.groupMembers),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return ScaffoldMessenger(
                  child: SnackBar(content: Text(snapshot.error.toString())));
            } else {
              List<Profile> friendsNotAMember = snapshot.data!;

              return ListView.builder(
                itemCount: friendsNotAMember.length,
                itemBuilder: (context, index) {
                  return _buildProfileListItem(friendsNotAMember[index]);
                },
              );
            }
          },
        ));
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
                    )
          ),
          onTap: () {
            onTileClicked(profile);
          },
        ),
        const Divider(),
      ],
    );
  }
}
