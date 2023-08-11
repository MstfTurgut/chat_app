import '../../../product/db/database.dart';
import '../../model/group.dart';
import '../../model/profile.dart';

class NewGroupViewModel {



  final _database = Database();


  Future<void> newGroup({required Profile currentProfile , required List<Profile> members ,required String groupName}) async{

    Group newGroup = Group(
    groupId: DateTime.now().millisecondsSinceEpoch.toString(), 
    groupName: groupName,
    adminIdList: [currentProfile.uid]);

    await _database.addNewGroup(group: newGroup.toJson());

    // adding current profile in members too 

    members.add(currentProfile);

    // making this group to access every member by adding profile maps to the group subcollection (members)

    for (var profile in members) {

      await _database.addMemberToGroup(groupId: newGroup.groupId ,profileMap: profile.toJson());

    }

    // making every profile to access this group by adding group id to these profiles properties

    for (var profile in members) {

      List<Group> groupChats = [];

      for (var group in profile.groups) {
        groupChats.add(group);
      }

      groupChats.add(newGroup);

      List<Map<String,dynamic>> newGroupChatsMap = groupChats.map((group) => group.toJson()).toList();

      await _database.updateProfile(updateMap:{'groups' : newGroupChatsMap},uid: profile.uid);
      
    }

    // make the current profile admin by default 

  }


  /// adding group to chat_rooms 

  /// adding group to members







}