import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:untitled/api/apis.dart';

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
    return APIs.user.uid == widget.msg.fromId
        ? _greenMessage()
        : _blueMessage();
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
            padding: EdgeInsets.all(mq.width * 0.04),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 221, 245, 255),
              border: Border.all(color: Colors.lightBlue),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Text(
              widget.msg.msg,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * 0.04),
          child: Text(
            MyDateFormatter.getFormatDate(
                context: context, time: widget.msg.sent),
            style: TextStyle(fontSize: 13, color: Colors.black54),
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
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        Flexible(
          child: Container(
            margin: EdgeInsets.symmetric(
                vertical: mq.height * 0.02, horizontal: mq.width * 0.025),
            padding: EdgeInsets.all(mq.width * 0.04),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 218, 245, 176),
              border: Border.all(color: Colors.lightGreen),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomLeft: Radius.circular(30),
              ),
            ),
            child: Text(
              widget.msg.msg,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }
}
