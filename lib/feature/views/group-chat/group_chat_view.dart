import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/feature/views/group-chat/mixin/group_chat_view_mixin.dart';
import 'package:chat_app/product/components/my_text_field.dart';
import 'package:chat_app/feature/model/message.dart';
import 'package:chat_app/feature/views/direct-chat/image_preview.dart';
import 'package:chat_app/product/components/chat-bubbles/notice_bubble.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../product/components/chat-bubbles/group_chat_bubble.dart';
import '../../../product/components/chat-bubbles/image_bubble.dart';
import '../../../product/services/auth_service.dart';
import 'package:intl/intl.dart';
import '../../model/group.dart';

class GroupChatView extends StatefulWidget {
  const GroupChatView({
    super.key,
    required this.groupId,
  });

  final String groupId;

  @override
  State<GroupChatView> createState() => _GroupChatViewState();
}

class _GroupChatViewState extends State<GroupChatView> with GroupChatViewMixin{
 

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Group>(
        stream: groupChatViewModel.getGroupStream(widget.groupId),
        builder: (context, snapshot) {

          if (snapshot.hasError) {
                return ScaffoldMessenger(child: SnackBar(content: Text(snapshot.error.toString())));
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {

          Group group = snapshot.data!;

          return Scaffold(
            appBar: AppBar(
              leading: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 0, 4),
                child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back)),
              ),
              title: GestureDetector(
                onTap: () async{
                  await goToGroupInfoView(group);
                },
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: SizedBox(
                          height: 40,
                          width: 40,
                          child: CachedNetworkImage(
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      fit: BoxFit.contain,
                      imageUrl: group.groupPhotoUrl,
                      imageBuilder: (context, imageProvider) {
                        return CircleAvatar(
                          backgroundImage: imageProvider,
                        );
                      },
                    )),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(titleTrimmer(group.groupName)),
                  ],
                ),
              ),
              actions: [
                PopupMenuButton(
                  itemBuilder: (BuildContext context) => <PopupMenuEntry>[
                    PopupMenuItem(
                      onTap: () async{
                        await goToGroupInfoView(group);
                      },
                      child: const Text('Group Info'),
                    ),
                    PopupMenuItem(
                      onTap: exitGroup,
                      child: const Text('Exit Group'),
                    ),
                  ],
                ),
              ],
            ),
            body: Column(children: [
              Expanded(child: _buildMessageList()),
              _buildInputField(),
              const SizedBox(
                height: 5,
              )
            ]),
          );
        }});
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: groupChatViewModel.getMessageListStream(
          chatRoomId: widget.groupId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return ScaffoldMessenger(child: SnackBar(content: Text(snapshot.error.toString())));
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else {
          final messageList = snapshot.data;

          return ListView.builder(
            reverse: true,
            itemCount: messageList!.length + 1,
            itemBuilder: (context, index) {
              if (index == messageList.length) {
                return const SizedBox(
                  height: 80,
                );
              } else {
                return _buildMessageListItem(messageList[index]);
              }
            },
          );
        }
      },
    );
  }

  //Build message list item

  Widget _buildMessageListItem(Message message) {
    final authService = context.read<AuthService>();

    bool belongToCurrentProfile = authService.isCurrentEmail(message.senderEmail);

    var alignment = (belongToCurrentProfile)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    String formattedTime = DateFormat.Hm().format(message.timestamp.toDate());

    if(message.isNoticeMessage) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20 , horizontal: 70),
        child: NoticeBubble(noticeMessage: message.text!),
      );
    } else if (message.imageUrl != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(15, 5, 10, 0),
        child: GestureDetector(
          onTapDown: storePosition,
          onLongPress: (belongToCurrentProfile)?() async{
            await _showCustomMenu(message, widget.groupId);
          }:null,
          child: Container(
            alignment: alignment,
            child: ImageBubble(
                senderEmail: message.senderEmail,
                toGroup: true,
                imageUrl: message.imageUrl!,
                text: message.text,
                time: formattedTime),
          ),
        ),
      );  
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(15, 5, 10, 0),
        child: GestureDetector(
          onTapDown: storePosition,
          onLongPress: (belongToCurrentProfile)?() async{
            await _showCustomMenu(message, widget.groupId);
          }:null,
          child: Container(
            alignment: alignment,
            child: GroupChatBubble(
              senderEmail: message.senderEmail,
              belongToCurrentUser:
                  authService.isCurrentEmail(message.senderEmail),
              time: formattedTime,
              text: message.text!,
            ),
          ),
        ),
      );
    } 


  }

  //Build input field

  Widget _buildInputField() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: MyTextField(
            textColor: Colors.black,
            hintTextColor: Colors.grey,
            cursorColor: Colors.black,
            borderRadius: 10,
            fillColor: Colors.grey.shade200,
            obscureText: false,
            hintText: 'Send a message',
            controller: messageCtr,
          )),
          Padding(
            padding: const EdgeInsets.only(bottom: 7.0),
            child: IconButton(onPressed: () async {
                  File? image = await groupChatViewModel.getImage();

                  if (image != null) {

                    if (!mounted) return;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImagePreview(
                            toGroup: true,
                            chatRoomId: widget.groupId,
                            media: image),
                        ));
                  }
                }, icon:const Icon(Icons.camera_alt , size: 30,)),
          ),
          const SizedBox(
            width: 5,
          ),
          GestureDetector(
            onTap: sendMessage,
            child: Container(
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                  color: Colors.amber, borderRadius: BorderRadius.circular(20)),
              child: const Icon(
                Icons.arrow_forward,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _showCustomMenu(Message message , String groupId) async{
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    await showMenu(context: context, 
    position: RelativeRect.fromRect(
          tapPosition & const Size(40, 40), // smaller rect, the touch area
          Offset.zero & overlay.size   // Bigger rect, the entire screen
      ), 
    items: <PopupMenuEntry>[
      PopupMenuItem(
        onTap: () async{
          await groupChatViewModel.deleteMessageFromGroup(message, groupId);
        },
        child: const Icon(Icons.delete))
    ]);


  }
}
