import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:untitled/api/apis.dart';
import 'package:untitled/helper/my_date_formatter.dart';

import 'package:untitled/main.dart';
import 'package:untitled/screens/chat_screen.dart';
import '../models/chat_user.dart';
import '../models/messages.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Message? _lastMessage;
  List<Message> _listOfMessages = [];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.symmetric(horizontal: mq.width * 0.01, vertical: 1),
      child: InkWell(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ChatScreen(user: widget.user)));
          },
          child: StreamBuilder(
            stream: APIs.getLastMessage(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;

              _listOfMessages =
                  data?.map((user) => Message.fromJson(user.data())).toList() ??
                      [];
              if (_listOfMessages.isNotEmpty) {
                _lastMessage = _listOfMessages[0];
              }
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .03),
                  child: CachedNetworkImage(
                    width: mq.height * .055,
                    height: mq.height * .055,
                    fit: BoxFit.cover,
                    imageUrl: widget.user.image,
                    errorWidget: (context, url, error) =>
                        const CircleAvatar(child: Icon(CupertinoIcons.person)),
                  ),
                ),
                title: Text(widget.user.name),
                subtitle: Text(
                  _lastMessage != null ? _lastMessage!.msg : widget.user.about,
                  maxLines: 1,
                ),
                trailing: _lastMessage == null ? null : _lastMessage!.read.isEmpty && _lastMessage!.fromId != APIs.user.uid ? Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                      color: Colors.greenAccent.shade400,
                      borderRadius: BorderRadius.circular(10)),
                )
                : Text(MyDateFormatter.getLastMessageTime(context: context, time: _lastMessage!.sent), style: TextStyle(color: Colors.black54),)
              );
            },
          )),
    );
  }
}
