import 'package:chat_app/feature/views/home/friends_list_view.dart';
import 'package:chat_app/feature/views/home/group_chats_list_view.dart';
import 'package:flutter/material.dart';
import 'mixin/home_view_mixin.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with HomeViewMixin{


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
            appBar: AppBar(
              title: const Text('Chat App'),
              actions: [
                IconButton(onPressed: goToFriendTabbar,icon: const Icon(Icons.person_add)),
                PopupMenuButton(
          itemBuilder: (BuildContext context) => <PopupMenuEntry>[
            PopupMenuItem(
              onTap: newGroup,
              child: const Text('New Group'),
            ),
            PopupMenuItem(
              onTap: goToSettings,
              child: const Text('Profile Settings'),
            ),
            PopupMenuItem(
              onTap: signOut,
              child: const Text('Log out'),
            ),
            
          ],
        ),
              ],
            ),
            body: const Column(
              children: [
                TabBar(
                  labelColor: Colors.amber,
                          indicatorColor: Colors.amber,
                          unselectedLabelColor: Colors.black,
                  tabs: [
                    Tab(
                      text: 'Direct Messages',
                    ),
                    Tab(
                      text: 'Group Chats',
                    ),
                  ]
                ),
                Expanded(child: 
                TabBarView(children: [
                  FriendsListView(),
                  GroupChatsListView(),
                ],))
              ],
            )
      ),
    );
  }

}
