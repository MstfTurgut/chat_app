import 'package:chat_app/feature/model/group.dart';
import 'package:json_annotation/json_annotation.dart';

part 'profile.g.dart';

@JsonSerializable()
class Profile {
  
  final String uid;

  final String email;

  final String profilePhotoUrl;


  @JsonKey(toJson: _groupsToJson)
  final List<Group> groups;


  Profile(
      {this.profilePhotoUrl =
          'https://firebasestorage.googleapis.com/v0/b/chat-app-demo-7ebb6.appspot.com/o/profilePhotos%2Fprofile.jpg?alt=media&token=c46cf299-2000-44b9-a2ff-0f7388584299',
      required this.uid,
      required this.email,
      this.groups = const [],
      });

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);

  static _groupsToJson(List<Group> groups) {
    groups.map((group) => group.toJson()).toList();
  }


}
