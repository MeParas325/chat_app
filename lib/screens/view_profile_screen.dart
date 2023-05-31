import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:untitled/helper/my_date_formatter.dart';

import '../main.dart';
import '../models/chat_user.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfileScreen({super.key, required this.user});

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.user.name),
        ),
        floatingActionButton: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Joined On: ', style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.bold),),
              Text(MyDateFormatter.getLastMessageTime(context: context, time: widget.user.created_At, year: true), style: TextStyle(color: Colors.black54, fontSize: 11),)
                ],
              ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.height * 0.05),
          child: SingleChildScrollView(
            child: Column(children: [
              SizedBox(
                height: mq.height * 0.05,
              ),
              SizedBox(width: mq.width,),
              ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * .1),
                    child: CachedNetworkImage(
                      width: mq.height * .2,
                      height: mq.height * .2,
                      fit: BoxFit.cover,
                      imageUrl: widget.user.image,
                      errorWidget: (context, url, error) =>
                          const CircleAvatar(
                              child: Icon(CupertinoIcons.person)),
                    ),
                  ),
              SizedBox(
                height: mq.height * .05,
              ),
              Text(
                widget.user.email,
                style: TextStyle(color: Colors.black87, fontSize: 15),
              ),
              SizedBox(
                height: mq.height * 0.02,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('About: ', style: TextStyle(color: Colors.black54, fontSize: 16, fontWeight: FontWeight.bold, ),),
              Text(widget.user.about, style: TextStyle(color: Colors.black54, fontSize: 14),)
                ],
              ),

              
            
            ]),
          ),
        ),
        
      ),
    );
  }
}
