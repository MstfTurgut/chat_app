// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
      profilePhotoUrl: json['profilePhotoUrl'] as String? ??
          'https://firebasestorage.googleapis.com/v0/b/chat-app-demo-7ebb6.appspot.com/o/profilePhotos%2Fprofile.jpg?alt=media&token=c46cf299-2000-44b9-a2ff-0f7388584299',
      uid: json['uid'] as String,
      email: json['email'] as String,
      groups: (json['groups'] as List<dynamic>?)
              ?.map((e) => Group.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ProfileToJson(Profile instance) => <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'profilePhotoUrl': instance.profilePhotoUrl,
      'groups': Profile._groupsToJson(instance.groups),
    };
