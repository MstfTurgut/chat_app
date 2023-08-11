import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

import '../../../product/error_dialog.dart';
import '../../../product/services/auth_service.dart';
import '../../model/profile.dart';
import '../../view-models/home/friends_list_view_model.dart';
import '../direct-chat/chat_view.dart';

class FriendsListView extends StatefulWidget {
  const FriendsListView({super.key});

  @override
  State<FriendsListView> createState() => _FriendsListViewState();
}

class _FriendsListViewState extends State<FriendsListView> {
  final _friendsListViewModel = FriendsListViewModel();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Profile>>(
      stream: _friendsListViewModel.getFriendsProfilesStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ScaffoldMessenger(
              child: SnackBar(content: Text(snapshot.error.toString())));
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          List<Profile> friendList = snapshot.data!;

          return (snapshot.data != null)
              ? ListView.builder(
                  itemCount: friendList.length,
                  itemBuilder: (context, index) {
                    return _buildProfileListItem(friendList[index]);
                  },
                )
              : const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildProfileListItem(Profile profile) {
    final authService = context.read<AuthService>();

    return Column(
      children: [
        Slidable(
          startActionPane: ActionPane(
              extentRatio: 0.25,
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                    icon: Icons.remove,
                    backgroundColor: Colors.red,
                    label: 'Unfriend',
                    onPressed: (_) async {
                      await showMyUnfriendConfirmDialog(profile);
                    })
              ]),
          child: ListTile(
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
            onTap: () async {
              Profile currentProfile = await authService.getCurrentProfile();

              if (!mounted) return;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatView(
                      currentProfile: currentProfile,
                      receiverProfile: profile,
                    ),
                  ));
            },
          ),
        ),
        const Divider(),
      ],
    );
  }

  Future<void> showMyUnfriendConfirmDialog(Profile profile) {
    bool isClicked = false;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Unfriend ${profile.email} ?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              onPressed: (!isClicked)
                  ? () async {
                      isClicked = true;
                      if (!mounted) return;
                      Navigator.pop(context);
                      try {
                        await _friendsListViewModel.unfriend(
                            friendUid: profile.uid);
                      } catch (e) {
                        await showErrorDialog(Text('$e'), context);
                      }
                    }
                  : null,
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
