import 'package:chat_app/feature/view-models/friend-tabbar/friend_tabbar_view_model.dart';
import 'package:chat_app/feature/views/friend-tabbar/add_friend_view.dart';
import 'package:chat_app/feature/views/friend-tabbar/friend_requests_view.dart';
import 'package:flutter/material.dart';
import '../../model/profile.dart';

class FriendTabbarView extends StatelessWidget {
  FriendTabbarView({super.key});

  final _friendTabbarViewModel = FriendTabbarViewModel();


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Add Friend'),
          ),
          body: StreamBuilder<List<Profile>>(
              stream: _friendTabbarViewModel.getRequestProfilesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return ScaffoldMessenger(child: SnackBar(content: Text(snapshot.error.toString())));
                } else if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
    
                  bool doesHaveRequest = snapshot.data!.isNotEmpty;
    
                  return Column(
                    children: [
                      TabBar(
                          labelColor: Colors.amber,
                          indicatorColor: Colors.amber,
                          unselectedLabelColor: Colors.black,
                          tabs: [
                            const Tab(
                              text: 'Add Friend',
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Friend Requests'),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  (doesHaveRequest)?Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(4)),
                                  ):const SizedBox(height: 0,),
                                ],
                              ),
                            )
                          ]),
                      Expanded(
                        child: TabBarView(children: [
                          const AddFriendView(),
                          FriendRequestsView(friendRequests: snapshot.data!,),
                        ]),
                      ),
                    ],
                  );
                }
              }),
        ),
      
    );
  }
}
