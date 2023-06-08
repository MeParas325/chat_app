import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:untitled/api/apis.dart';
import 'package:untitled/helper/dialogs.dart';

import '../helper/my_date_formatter.dart';
import '../main.dart';
import '../models/messages.dart';

class MessageCard extends StatefulWidget {
  final Message msg;
  const MessageCard({super.key, required this.msg});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user!.uid == widget.msg.fromId;

    return InkWell(
      onLongPress: () {
        showBottomModelView(isMe, context);
      },
      child: isMe ? _greenMessage() : _blueMessage(),
    );
  }

  Widget _blueMessage() {
    if (widget.msg.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.msg);
      log("message status updated.");
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(
                vertical: mq.height * 0.02, horizontal: mq.width * 0.025),
            padding: EdgeInsets.all(widget.msg.type == Type.text
                ? mq.width * 0.04
                : mq.width * 0.03),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 221, 245, 255),
              border: Border.all(color: Colors.lightBlue),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: widget.msg.type == Type.text
                ? Text(
                    widget.msg.msg,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                        imageUrl: widget.msg.msg,
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.image)),
                  ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * 0.04),
          child: Text(
            MyDateFormatter.getFormatDate(
                context: context, time: widget.msg.sent),
            style: TextStyle(fontSize: 13, color: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.black54 : Colors.white38),
          ),
        ),
      ],
    );
  }

  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: mq.width * 0.02,
            ),
            if (widget.msg.read.isNotEmpty)
              Icon(
                Icons.done_all_rounded,
                size: 15,
                color: Colors.blue,
              ),
            SizedBox(
              width: 3,
            ),
            Text(
              MyDateFormatter.getFormatDate(
                  context: context, time: widget.msg.sent),
              style: TextStyle(fontSize: 13, color: MediaQuery.of(context).platformBrightness == Brightness.light ? Colors.black54 : Colors.white38),
            ),
          ],
        ),
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(
                vertical: mq.height * 0.02, horizontal: mq.width * 0.025),
            padding: EdgeInsets.all(widget.msg.type == Type.text
                ? mq.width * 0.04
                : mq.width * 0.03),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 218, 245, 176),
              border: Border.all(color: Colors.lightGreen),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
            ),
            child: widget.msg.type == Type.text
                ? Text(
                    widget.msg.msg,
                    style: TextStyle(fontSize: 16, color: Colors.black87),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                        imageUrl: widget.msg.msg,
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.image)),
                  ),
          ),
        ),
      ],
    );
  }

  void showBottomModelView(bool isMe, BuildContext context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        context: context,
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * 0.01, horizontal: mq.width * 0.4),
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(8.0)),
              ),

              widget.msg.type == Type.text
                  ?
                  // copy option
                  _OptionItem(
                      icon: Icon(
                        Icons.copy_outlined,
                        color: Colors.blue,
                      ),
                      name: 'Copy Text',
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.msg.msg))
                            .then((value) {
                          // for hiding bottom sheet
                          Navigator.pop(context);

                          Dialogs.showSnackbar(context, 'Text Copied');
                        });
                      })
                  :
                  // save image option
                  _OptionItem(
                      icon: Icon(
                        Icons.download,
                        color: Colors.blue,
                      ),
                      name: 'Save Image',
                      onTap: () {
                        GallerySaver.saveImage(widget.msg.msg, albumName: 'Our Chat').then((success) {
                          // for hiding bottom sheet
                          Navigator.pop(context);

                          if (success != null && success) {
                            Dialogs.showSnackbar(
                                context, 'Image Saved Successfully!');
                          }
                        });
                      }),

              // seperator or divider
              Divider(
                color: Colors.black54,
                indent: mq.width * 0.04,
                endIndent: mq.width * 0.04,
              ),

              if (widget.msg.type == Type.text && isMe)
                // edit option
                _OptionItem(
                    icon: Icon(
                      Icons.edit,
                      color: Colors.blue,
                      size: 26,
                    ),
                    name: 'Edit Message',
                    onTap: () async {}),

              if (isMe)
                // delete option
                _OptionItem(
                    icon:
                        Icon(Icons.delete_forever, color: Colors.red, size: 26),
                    name: 'Delete Message',
                    onTap: () {
                      APIs.deleteMessage(widget.msg);

                      // for hiding bottom sheet
                      Navigator.pop(context);

                      Dialogs.showSnackbar(context, 'Message Deleted');
                    }),

              if (isMe)
                // seperator or divider
                Divider(
                  color: Colors.black54,
                  indent: mq.width * 0.04,
                  endIndent: mq.width * 0.04,
                ),

              // sent time
              _OptionItem(
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: Colors.blue,
                  ),
                  name:
                      'Sent At: ${MyDateFormatter.getMessageTime(context: context, time: widget.msg.sent)}',
                  onTap: () {}),

              // read time
              _OptionItem(
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: Colors.green,
                  ),
                  name: widget.msg.read.isEmpty
                      ? 'Read At: Not seen yet'
                      : 'Read At: ${MyDateFormatter.getMessageTime(context: context, time: widget.msg.read)}',
                  onTap: () {}),
            ],
          );
        });
  }
}

class _OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(
            top: mq.height * 0.01,
            left: mq.width * 0.05,
            bottom: mq.height * 0.01),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
              '    $name',
              style: TextStyle(
                  fontSize: 15, color: Colors.black54, letterSpacing: 0.5),
            ))
          ],
        ),
      ),
    );
  }
}
