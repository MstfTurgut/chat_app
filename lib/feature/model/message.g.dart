// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      isNoticeMessage: json['isNoticeMessage'] as bool? ?? false,
      senderEmail: json['senderEmail'] as String,
      receiverId: json['receiverId'] as String,
      text: json['text'] as String?,
      imageUrl: json['imageUrl'] as String?,
      timestamp: Message._timestampFromString(json['timestamp'] as String),
      senderId: json['senderId'] as String,
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'senderId': instance.senderId,
      'senderEmail': instance.senderEmail,
      'receiverId': instance.receiverId,
      'text': instance.text,
      'imageUrl': instance.imageUrl,
      'isNoticeMessage': instance.isNoticeMessage,
      'timestamp': Message._timestampToString(instance.timestamp),
    };
