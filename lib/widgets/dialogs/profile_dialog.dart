import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/chat_user.dart';
import '../../screens/view_profile_screen.dart';

class ProfileDialog extends StatelessWidget {
  final ChatUser user;
  const ProfileDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(0),
      backgroundColor: Colors.white.withOpacity(.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: SizedBox(
        width: mq.width * .6,
        height: mq.height * .35,
        child: Stack(
          children: [
            Positioned(
                left: mq.width * 0.05,
                top: mq.height * 0.015,
                child: Text(
                  user.name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                )),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                  onPressed: (() {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ViewProfileScreen(
                                  user: user,
                                )));
                  }),
                  icon: Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                  )),
            ),
            Align(
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(mq.height * .125),
                child: CachedNetworkImage(
                  width: mq.height * .25,
                  height: mq.height * .25,
                  fit: BoxFit.cover,
                  imageUrl: user.image,
                  errorWidget: (context, url, error) =>
                      const CircleAvatar(child: Icon(CupertinoIcons.person)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
