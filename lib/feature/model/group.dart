import 'package:json_annotation/json_annotation.dart';

part 'group.g.dart';

@JsonSerializable()
class Group {

  final String groupId;
  final String groupName;
  final String groupPhotoUrl;
  final List<String> adminIdList;

  // groups will have collections of profiles which named admins and members 

  Group({
    this.adminIdList = const [], 
    this.groupPhotoUrl = 'https://firebasestorage.googleapis.com/v0/b/chat-app-demo-7ebb6.appspot.com/o/groupProfilePhotos%2Fgroup_default.png?alt=media&token=d8255e17-cb5a-44ec-bfbc-8258d00574db',
    required this.groupId,
    required this.groupName,
  });


  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);

  Map<String, dynamic> toJson() => _$GroupToJson(this);



}