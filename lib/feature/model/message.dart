import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message.g.dart';

@JsonSerializable()
class Message {
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String? text;
  final String? imageUrl;
  final bool isNoticeMessage;

  @JsonKey(toJson: _timestampToString,fromJson: _timestampFromString)
  final Timestamp timestamp;

  Message({
    this.isNoticeMessage = false,
    required this.senderEmail,
    required this.receiverId,
    this.text,
    this.imageUrl,
    required this.timestamp,
    required this.senderId,
  });


  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);


  static Timestamp _timestampFromString(String value) => Timestamp.fromMillisecondsSinceEpoch(int.parse(value));

  static String _timestampToString(Timestamp timestamp) => timestamp.millisecondsSinceEpoch.toString();


}
