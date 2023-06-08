import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:untitled/widgets/chat_user_card.dart';
import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../models/chat_user.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  List<ChatUser> _list = [];
  final List<ChatUser> _searchList = [];

  bool _isSearching = false;

  @override
  void initState() {
    // WidgetsBinding.instance.addObserver(this);
    APIs.getSelfInfo();
    super.initState();

    SystemChannels.lifecycle.setMessageHandler((message) {
      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('resume'))
          APIs.updateActiveStatus(true);
        if (message.toString().contains('pause'))
          APIs.updateActiveStatus(false);
      }
      return Future.value(message);
    });
  }

  // @override
  // void didChangePlatformBrightness() {
  //   log("Theme changes");
  //   if(MediaQuery.of(context).platformBrightness == Brightness.light) {

  //     SystemChrome.setSystemUIOverlayStyle(
  //       SystemUiOverlayStyle(statusBarColor: Colors.black));

  //   } else {

  //     SystemChrome.setSystemUIOverlayStyle(
  //       SystemUiOverlayStyle(statusBarColor: Colors.white));

  //   }

  //   super.didChangePlatformBrightness();
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            return Future.value(false);
          } else {
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
              leading: _isSearching
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          _isSearching = !_isSearching;
                        });
                      },
                      icon: Icon(CupertinoIcons.arrow_left))
                  : MediaQuery.of(context).platformBrightness ==
                          Brightness.light
                      ? Icon(CupertinoIcons.sun_max_fill)
                      : Icon(
                          CupertinoIcons.moon_fill,
                          color: Colors.white,
                        ),
              title: _isSearching
                  ? TextField(
                      autofocus: true,
                      onChanged: (value) {
                        _searchList.clear();
                        if (value.isNotEmpty) {
                          for (var i in _list) {
                            if (i.name
                                    .toLowerCase()
                                    .contains(value.toLowerCase()) ||
                                i.email
                                    .toLowerCase()
                                    .contains(value.toLowerCase())) {
                              _searchList.add(i);
                              setState(() {
                                _searchList;
                              });
                            }
                          }
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by name, email...',
                        border: InputBorder.none,
                      ),
                    )
                  : Text("We Chat"),
              actions: [
                _isSearching
                    ? Container()
                    : IconButton(
                        onPressed: () {
                          setState(() {
                            _isSearching = !_isSearching;
                          });
                        },
                        icon: Icon(Icons.search)),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ProfileScreen(
                                    user: APIs.me,
                                  )));
                    },
                    icon: Icon(Icons.more_vert)),
              ]),
          body: StreamBuilder(
              stream: APIs.getMyUsersId(),

              // get id of only known users
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    return Center(
                      child: CircularProgressIndicator(),
                    );

                  case ConnectionState.active:
                  case ConnectionState.done:
                    return StreamBuilder(
                        stream: APIs.getAllUsers(
                            snapshot.data?.docs.map((doc) => doc.id).toList() ??
                                []),

                        // get only those users whose Ids are provided
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                            case ConnectionState.none:
                            // return Center(
                            //   child: CircularProgressIndicator(),
                            // );

                            case ConnectionState.active:
                            case ConnectionState.done:
                              final data = snapshot.data?.docs;

                              _list = data
                                      ?.map((user) =>
                                          ChatUser.fromJson(user.data()))
                                      .toList() ??
                                  [];
                              // log('Data: ${usersData}');

                              if (_list.isNotEmpty) {
                                return ListView.builder(
                                    physics: BouncingScrollPhysics(),
                                    itemCount: _isSearching
                                        ? _searchList.length
                                        : _list.length,
                                    itemBuilder: (context, index) {
                                      return ChatUserCard(
                                        user: _isSearching
                                            ? _searchList[index]
                                            : _list[index],
                                      );
                                    });
                              } else {
                                return Center(
                                    child: Text(
                                  "No Connections Found!",
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.black54),
                                ));
                              }
                          }
                        });
                }
              }),
          floatingActionButton: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                onPressed: () {
                  _addChatUserDialog();
                },
                child: Icon(
                  Icons.add_comment_rounded,
                ),
              )),
        ),
      ),
    );
  }

  // for adding new chat user
  void _addChatUserDialog() {
    String email = '';

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: Row(
                children: const [
                  Icon(
                    Icons.person_add,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text('  Add User')
                ],
              ),

              //content
              content: TextFormField(
                maxLines: null,
                onChanged: (value) => email = value,
                decoration: InputDecoration(
                    hintText: 'Email Id',
                    prefixIcon: const Icon(Icons.email, color: Colors.blue),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.blue, fontSize: 16))),

                //add button
                MaterialButton(
                    onPressed: () async {
                      //hide alert dialog
                      Navigator.pop(context);
                      if (email.isNotEmpty) {
                        await APIs.addChatUser(email).then((value) {
                          if (!value) {
                            Dialogs.showSnackbar(
                                context, 'User does not Exists!');
                          }
                        });
                      }
                    },
                    child: const Text(
                      'Add',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));
  }
}
