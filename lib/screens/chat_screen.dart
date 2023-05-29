import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled/helper/my_date_formatter.dart';
import 'package:untitled/widgets/message_card.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/messages.dart';
import 'view_profile_screen.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  bool _showEmojis = false, _isUploading = false;
  List<Message> _listOfMessages = [];

  final _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (_showEmojis) {
              setState(() {
                _showEmojis = false;
              });

              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
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
                      stream: APIs.getAllMessages(widget.user),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.none:
                            return Center(
                              child: SizedBox(),
                            );

                          case ConnectionState.active:
                          case ConnectionState.done:
                            final data = snapshot.data?.docs;

                            _listOfMessages = data
                                    ?.map(
                                        (user) => Message.fromJson(user.data()))
                                    .toList() ??
                                [];
                            log('Data: ${_listOfMessages}');

                            if (_listOfMessages.isNotEmpty) {
                              return ListView.builder(
                                  reverse: true,
                                  physics: BouncingScrollPhysics(),
                                  itemCount: _listOfMessages.length,
                                  itemBuilder: (context, index) {
                                    return MessageCard(
                                        msg: _listOfMessages[index]);
                                  });
                            } else {
                              return Center(
                                  child: Text(
                                "Say hi!👋",
                                style: TextStyle(
                                    fontSize: 17, color: Colors.black54),
                              ));
                            }
                        }
                      }),
                ),
                if (_isUploading)
                  Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )),
                _chatInputField(),
                if (_showEmojis)
                  SizedBox(
                    height: mq.height * 0.35,
                    child: EmojiPicker(
                      textEditingController:
                          _textController, // pass here the same [TextEditingController] that is connected to your input field, usually a [TextFormField]
                      config: Config(
                        columns: 7,
                        emojiSizeMax: 32 *
                            (Platform.isIOS
                                ? 1.30
                                : 1.0), // Issue: https://github.com/flutter/flutter/issues/28894
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewProfileScreen(user: widget.user)));
        },
        child: StreamBuilder(
            stream: APIs.getUserInfo(widget.user),
            builder: ((context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];
              return Row(
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
                      imageUrl:
                          list.isNotEmpty ? list[0].image : widget.user.image,
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
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
                        list.isNotEmpty ? list[0].name : widget.user.name,
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        list.isNotEmpty
                            ? list[0].isOnline
                                ? 'online'
                                : list.isNotEmpty
                                    ? MyDateFormatter.getlastActiveTime(
                                        context: context,
                                        lastActive: list[0].lastActive)
                                    : MyDateFormatter.getlastActiveTime(
                                        context: context,
                                        lastActive: widget.user.lastActive)
                            : MyDateFormatter.getlastActiveTime(
                                context: context,
                                lastActive: widget.user.lastActive),
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                ],
              );
            })));
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
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _showEmojis = !_showEmojis;
                        });
                      },
                      icon: Icon(
                        Icons.emoji_emotions,
                        color: Colors.blueAccent,
                        size: 25,
                      )),
                  Expanded(
                      child: TextField(
                    controller: _textController,
                    keyboardType: TextInputType.multiline,
                    onTap: (() {
                      if (_showEmojis)
                        setState(() => _showEmojis = !_showEmojis);
                    }),
                    maxLines: null,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type something..',
                        hintStyle: TextStyle(color: Colors.blueAccent)),
                  )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // open camera
                        List<XFile> images = await picker.pickMultiImage();

                        if (images.isNotEmpty) {
                          // log('ImagePath: ${images.path}');
                          for (var i in images) {
                            setState(() => _isUploading = true);
                            await APIs.sendChatImage(widget.user, File(i.path));
                            setState(() => _isUploading = false);
                          }
                        }
                      },
                      icon: Icon(
                        Icons.image,
                        color: Colors.blueAccent,
                        size: 26,
                      )),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // open camera
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);

                        if (image != null) {
                          log('ImagePath: ${image.path}');
                          setState(() => _isUploading = true);
                          await APIs.sendChatImage(
                              widget.user, File(image.path));
                          setState(() => _isUploading = false);
                        }
                      },
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
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                APIs.sendMessage(widget.user, _textController.text, Type.text);
                _textController.text = '';
              }
            },
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
