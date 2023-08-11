// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Group _$GroupFromJson(Map<String, dynamic> json) => Group(
      adminIdList: (json['adminIdList'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      groupPhotoUrl: json['groupPhotoUrl'] as String? ??
          'https://firebasestorage.googleapis.com/v0/b/chat-app-demo-7ebb6.appspot.com/o/groupProfilePhotos%2Fgroup_default.png?alt=media&token=d8255e17-cb5a-44ec-bfbc-8258d00574db',
      groupId: json['groupId'] as String,
      groupName: json['groupName'] as String,
    );

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
      'groupId': instance.groupId,
      'groupName': instance.groupName,
      'groupPhotoUrl': instance.groupPhotoUrl,
      'adminIdList': instance.adminIdList,
    };
