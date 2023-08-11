import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/product/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../model/group.dart';
import '../../model/profile.dart';
import '../group-chat/group_chat_view.dart';

class GroupChatsListView extends StatefulWidget {
  const GroupChatsListView({super.key});

  @override
  State<GroupChatsListView> createState() => _GroupChatsListViewState();
}

class _GroupChatsListViewState extends State<GroupChatsListView> {



  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Profile>(
        stream: context.watch<AuthService>().currentProfileStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ScaffoldMessenger(child: SnackBar(content: Text(snapshot.error.toString())));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {

            List<Group> groupList = snapshot.data!.groups;

            return ListView.builder(
              itemCount: groupList.length,
              itemBuilder: (context, index) {
                return _buildGroupListItem(groupList[index]);
              },);                                                                  

          }
        });
  }


  Widget _buildGroupListItem(Group group) {

      return Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all( 15),
            title: Text(
              group.groupName,
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
                      imageUrl: group.groupPhotoUrl,
                      imageBuilder: (context, imageProvider) {
                        return CircleAvatar(
                          backgroundImage: imageProvider,
                        );
                      },
                    ),
            ),
            onTap: () async {
          
              if (!mounted) return;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupChatView(groupId: group.groupId,),
                  ));
            },
          ),
          const Divider(),
        ],
      );
    
  }
}
