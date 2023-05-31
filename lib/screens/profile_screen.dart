import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

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

  String? imagePath;

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
                SizedBox(
                  height: mq.height * 0.05,
                ),
                Stack(children: [
                  imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * .1),
                          child: Image.file(
                            File(imagePath!),
                            width: mq.height * .2,
                            height: mq.height * .2,
                            fit: BoxFit.cover,
                          ),
                        ) :
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
                  Positioned(
                      right: 0,
                      bottom: 0,
                      child: MaterialButton(
                        elevation: 2,
                        shape: CircleBorder(),
                        onPressed: () {
                          // print("Inside edit buttom function");
                          showBottomModelView(context);
                        },
                        child: Icon(
                          Icons.edit,
                          color: Colors.blue,
                        ),
                        color: Colors.white,
                      )),
                ]),
                SizedBox(
                  height: mq.height * .02,
                ),
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
                            context, 'Username updated successfully.');
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
              await APIs.updateActiveStatus(false);
              Dialogs.showProgressBar(context);
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  APIs.auth = FirebaseAuth.instance;
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

  void showBottomModelView(BuildContext context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        context: context,
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(
                top: mq.height * 0.03, bottom: mq.height * 0.05),
            children: [
              Text(
                "Pick Profile Picture",
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
              ),
              SizedBox(
                height: mq.height * 0.02,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        backgroundColor: Colors.white,
                        fixedSize: Size(mq.width * 0.3, mq.height * 0.15),
                      ),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery);

                        if (image != null) {
                          log('ImagePath: ${image.path}');
                          setState(() {
                            imagePath = image.path;
                          });
                          await APIs.updateProfilePhoto(File(image.path));
                          Navigator.of(context).pop();
                          Dialogs.showSnackbar(
                              context, 'Profile picture updated successfully.');
                        }
                      },
                      child: Image.asset("assets/icon/add_image.png")),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        backgroundColor: Colors.white,
                        fixedSize: Size(mq.width * 0.3, mq.height * 0.15),
                      ),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // open camera
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);

                        if (image != null) {
                          log('ImagePath: ${image.path}');
                          setState(() {
                            imagePath = image.path;
                          });
                          await APIs.updateProfilePhoto(File(image.path));
                          Navigator.of(context).pop();
                          Dialogs.showSnackbar(
                              context, 'Profile picture updated successfully.');
                        }
                      },
                      child: Image.asset("assets/icon/camera.png")),
                ],
              ),
            ],
          );
        });
  }
}
