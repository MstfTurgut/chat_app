import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/product/error_dialog.dart';
import 'package:chat_app/product/services/auth_service.dart';
import 'package:chat_app/feature/view-models/friend-tabbar/friend_requests_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/profile.dart';

class FriendRequestsView extends StatefulWidget {
  const FriendRequestsView({super.key, required this.friendRequests});

  final List<Profile> friendRequests;

  @override
  State<FriendRequestsView> createState() => _FriendRequestsViewState();
}

class _FriendRequestsViewState extends State<FriendRequestsView> {
  final _friendRequestViewModel = FriendRequestsViewModel();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.friendRequests.length,
      itemBuilder: (context, index) {
        return _buildRequestCard(widget.friendRequests[index]);
      },
    );
  }

  Widget _buildRequestCard(Profile senderProfile) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 90,
        child: Card(
          color: Colors.amber.shade50,
          child: Center(
            child: ListTile(
              leading: SizedBox(
                  width: 50,
                  height: 50,
                  child: CachedNetworkImage(
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      fit: BoxFit.contain,
                      imageUrl: senderProfile.profilePhotoUrl,
                      imageBuilder: (context, imageProvider) {
                        return CircleAvatar(
                          backgroundImage: imageProvider,
                        );
                      },
                    )),
              title: Text(
                senderProfile.email,
                style: const TextStyle(fontSize: 17),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                      onPressed: () async {
                        Profile currentProfile = await context
                            .read<AuthService>()
                            .getCurrentProfile();

                        if (!mounted) return;
                        try {
                          await _friendRequestViewModel.acceptFriendRequest(
                              currentProfile, senderProfile);
                        } catch (e) {
                          await showErrorDialog(Text('$e'), context);
                        }
                      },
                      icon: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 30,
                      )),
                  IconButton(
                      onPressed: () async {
                        try {
                          await _friendRequestViewModel
                              .rejectFriendRequest(senderProfile);
                        } catch (e) {
                          await showErrorDialog(Text('$e'), context);
                        }
                      },
                      icon: const Icon(
                        Icons.cancel,
                        color: Colors.red,
                        size: 30,
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
