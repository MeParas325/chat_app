import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled/main.dart';

import '../models/chat_user.dart';

class ChatUserCard extends StatefulWidget {
  
  final ChatUser user;
  const ChatUserCard({super.key, required this.user});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.symmetric(horizontal: mq.width * 0.01, vertical: 1),
      child: InkWell(
        onTap: () {
          print("Clicked");
        },
        child: ListTile(
          leading: CircleAvatar(child: Icon(CupertinoIcons.person)),
          title: Text(widget.user.name),
          subtitle: Text(
            widget.user.about,
            maxLines: 1,
          ),
          trailing: Text(
            "12.00 AM",
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ),
    );
  }
}
