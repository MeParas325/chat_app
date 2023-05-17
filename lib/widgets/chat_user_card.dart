import 'package:cached_network_image/cached_network_image.dart';
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
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(mq.height * 0.4),
              child: CachedNetworkImage(
                width: mq.width * 0.085,
                height: mq.height * 0.085,
                imageUrl: widget.user.image,
                errorWidget: (context, url, error) => CircleAvatar(
                  child: Icon(CupertinoIcons.person),
                ),
              ),
            ),
            title: Text(widget.user.name),
            subtitle: Text(
              widget.user.about,
              maxLines: 1,
            ),
            trailing: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                  color: Colors.greenAccent.shade400,
                  borderRadius: BorderRadius.circular(10)),
            )),
      ),
    );
  }
}
