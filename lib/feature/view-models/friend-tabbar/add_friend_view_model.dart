import 'package:chat_app/feature/model/profile.dart';
import 'package:chat_app/product/db/database.dart';
import 'package:flutter/material.dart';

class AddFriendViewModel extends ChangeNotifier {
  final _database = Database();

  // Convert the profiles data from querySnap to List profile

  // check if the profiles from list contains the given email and return bool

  Stream<List<Profile>> profileListStream() {
    var docSnapListStream = _database.getProfilesQuerySnapshotStream().map((querySnap) => querySnap.docs);

    var mapListStream = docSnapListStream.map((docSnapList) => docSnapList.map((docSnap) => docSnap.data() as Map<String,dynamic>).toList());

    var profileListStream = mapListStream.map((mapList) => mapList.map((map) => Profile.fromJson(map)).toList());

    return profileListStream;
  }

  bool belongToProfile(List<Profile> profiles, String email) {
    var emailList = profiles.map((profile) => profile.email).toList();

    return emailList.contains(email);
  }

  Future<bool> isAlreadyFriend({required String email}) async {

    var querySnap = await _database.getFriendsQuerySnapshot();

    var friendsEmailList = querySnap.docs.map((doc) => (doc.data() as Map<String , dynamic>)['email']).toList();

    return friendsEmailList.contains(email);

  }

  Future<bool> doesRequestAlreadySent({required Profile currentProfile ,required String email ,required List<Profile> profileList}) async {

    Profile? receiverProfile;

    for (var profile in profileList) {
      if(profile.email == email) {
        receiverProfile = profile;
      }
    }

    var querySnap = await _database.getRequestsQuerySnapshot(receiverProfile!.uid);

    var docList = querySnap.docs;

    var friendRequests = docList.map((doc) => Profile.fromJson(doc.data() as Map<String,dynamic>)).toList();

    var friendRequestsEmails = friendRequests.map((profile) => profile.email).toList();

    bool doesRequestAlreadySent = friendRequestsEmails.contains(currentProfile.email);

    return doesRequestAlreadySent;


  }

  Future<void> sendFriendRequest({required Profile currentProfile,required String receiverEmail,
      required List<Profile> profileList}) async{

        String? receiverId;

        for (var profile in profileList) {

          if(profile.email == receiverEmail) {
            receiverId = profile.uid;
          }
        }
        
        await _database.addRequest(profileMap: currentProfile.toJson(), receiverId: receiverId!);

  }



  
}

  


