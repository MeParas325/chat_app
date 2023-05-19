import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:untitled/widgets/message_card.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/messages.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  List<Message> _listOfMessages = [];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          flexibleSpace: _appBar(),
        ),
        backgroundColor: Color.fromARGB(255, 240, 247, 250),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                  stream: APIs.getAllMessages(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return Center(
                          child: CircularProgressIndicator(),
                        );

                      case ConnectionState.active:
                      case ConnectionState.done:
                        final data = snapshot.data?.docs;
                        log("Messages: ${jsonEncode(data![0].data())}");

                        // _usersData = data
                        //         ?.map((user) => ChatUser.fromJson(user.data()))
                        //         .toList() ??
                        //     [];
                        // log('Data: ${usersData}');
                        _listOfMessages.clear();
                        _listOfMessages.add(Message(
                            toId: 'xyz',
                            msg: 'hii',
                            read: '',
                            type: Type.text,
                            sent: '12:00 AM',
                            fromId: APIs.user.uid));

                        _listOfMessages.add(Message(
                            toId: APIs.user.uid,
                            msg: 'hello',
                            read: '',
                            type: Type.text,
                            sent: '12:05 AM',
                            fromId: 'xyz'));

                        if (_listOfMessages.isNotEmpty) {
                          return ListView.builder(
                              physics: BouncingScrollPhysics(),
                              itemCount: _listOfMessages.length,
                              itemBuilder: (context, index) {
                                return MessageCard(msg: _listOfMessages[index]);
                              });
                        } else {
                          return Center(
                              child: Text(
                            "Say hi!👋",
                            style:
                                TextStyle(fontSize: 17, color: Colors.black54),
                          ));
                        }
                    }
                  }),
            ),
            _chatInputField(),
          ],
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: Icon(CupertinoIcons.arrow_left)),
          ClipRRect(
            borderRadius: BorderRadius.circular(mq.height * .03),
            child: CachedNetworkImage(
              width: mq.height * .05,
              height: mq.height * .05,
              fit: BoxFit.cover,
              imageUrl: widget.user.image,
              errorWidget: (context, url, error) =>
                  const CircleAvatar(child: Icon(CupertinoIcons.person)),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user.name,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(
                height: 2,
              ),
              Text(
                "Last seen not available",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _chatInputField() {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: mq.width * 0.01, vertical: 0.02),
      child: Row(
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.emoji_emotions,
                        color: Colors.blueAccent,
                        size: 25,
                      )),
                  Expanded(
                      child: TextField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type something..',
                        hintStyle: TextStyle(color: Colors.blueAccent)),
                  )),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.image,
                        color: Colors.blueAccent,
                        size: 26,
                      )),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.camera_alt,
                        color: Colors.blueAccent,
                        size: 26,
                      )),
                ],
              ),
            ),
          ),
          MaterialButton(
            minWidth: 0,
            padding: EdgeInsets.only(top: 6, right: 6, bottom: 6, left: 9),
            shape: CircleBorder(),
            color: Colors.blue,
            onPressed: () {},
            child: Icon(
              Icons.send,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}