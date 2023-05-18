import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:untitled/helper/dialogs.dart';

import '../api/apis.dart';
import '../main.dart';
import '../models/chat_user.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    print(widget.user);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Your Profile"),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.height * 0.05),
            child: SingleChildScrollView(
              child: Column(children: [
                SizedBox(height: mq.height * 0.1 ,),
                Stack(children: [
                  CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                    widget.user.image,
                    maxWidth: 40,
                    maxHeight: 40,
                  ),
                  ),
                  
                  Positioned(
                      top: 0,
                      bottom: 0,
                      child: MaterialButton(
                        shape: CircleBorder(),
                        onPressed: () {},
                        child: Icon(Icons.edit),
                        color: Colors.blue,
                      )),
                ]),

                SizedBox(height: mq.height * .02,),

                Text(
                  widget.user.email,
                  style: TextStyle(color: Colors.black54, fontSize: 16),
                ),

                SizedBox(
                  height: mq.height * 0.05,
                ),

                TextFormField(
                  initialValue: widget.user.name,
                  onSaved: (newValue) => APIs.me.name = newValue ?? '',
                  validator: (value) => value != null && value.isNotEmpty
                      ? null
                      : 'Required Field',
                  decoration: InputDecoration(
                      label: Text("Username"),
                      hintText: "eg. Tanuja Juyal",
                      prefix: Icon(
                        Icons.person,
                        color: Colors.blue,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),

                SizedBox(
                  height: mq.height * 0.02,
                ),

                TextFormField(
                  initialValue: widget.user.about,
                  onSaved: (newValue) => APIs.me.about = newValue ?? '',
                  validator: (value) => value != null && value.isNotEmpty
                      ? null
                      : 'Required Field',
                  decoration: InputDecoration(
                      label: Text("About"),
                      hintText: "eg. Feeling Happy",
                      prefix: Icon(
                        Icons.info_outlined,
                        color: Colors.blue,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),

                SizedBox(
                  height: mq.height * 0.05,
                ),

                ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        APIs.updateUserInfo();
                        Dialogs.showSnackbar(
                            context, 'Profile Updated Successfully.');
                        log("Validator called");
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        shape: StadiumBorder(),
                        minimumSize: Size(mq.width * 0.5, mq.height * 0.05)),
                    icon: Icon(
                      Icons.edit,
                      size: 26,
                    ),
                    label: Text(
                      "Update",
                      style: TextStyle(fontSize: 16),
                    )),
              ]),
            ),
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.red,
            onPressed: () async {
              Dialogs.showProgressBar(context);
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => LoginScreen()));
                });
              });
            },
            icon: Icon(Icons.logout),
            label: Text("logout"),
          ),
        ),
      ),
    );
  }
}
