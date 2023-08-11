import 'package:chat_app/feature/view-models/group-chat/group_info_view_model.dart';
import '../../model/profile.dart';
import '../home/friends_list_view_model.dart';

class AddParticipantsViewModel {


  final _friendsListViewModel = FriendsListViewModel();
  final _groupInfoViewModel = GroupInfoViewModel();


  Future<void> addParticipants(List<Profile> newParticipants , String groupId) async{

    for (var profile in newParticipants) {
      await _groupInfoViewModel.addProfile(profile.uid, groupId);
    }


  }

  Future<List<Profile>> friendsNotAMember(String groupId , List<Profile> groupMembers) async{

    List<Profile> friendsNotAMember = [];

    List<Profile> friendList = await _friendsListViewModel.getFriendsProfiles();

    var membersIdList = groupMembers.map((member) => member.uid);

    for (int i = 0; i < friendList.length; i++) {

      if (!membersIdList.contains(friendList[i].uid)) {
        friendsNotAMember.add(friendList[i]);
      }

    }

    return friendsNotAMember;

  }










  
}