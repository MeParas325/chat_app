import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:untitled/widgets/chat_user_card.dart';
import '../api/apis.dart';
import '../models/chat_user.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ChatUser> _usersData = [];
  final List<ChatUser> _searchList = [];

  bool _isSearching = false;

  @override
  void initState() {
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
                  : Icon(CupertinoIcons.home),
              title: _isSearching
                  ? TextField(
                      autofocus: true,
                      onChanged: (value) {
                        _searchList.clear();
                        if (value.isNotEmpty) {
                          for (var i in _usersData) {
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
                  : Text("Our Chat"),
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
              stream: APIs.getAllUsers(),
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

                    _usersData = data
                            ?.map((user) => ChatUser.fromJson(user.data()))
                            .toList() ??
                        [];
                    // log('Data: ${usersData}');

                    if (_usersData.isNotEmpty) {
                      return ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: _isSearching
                              ? _searchList.length
                              : _usersData.length,
                          itemBuilder: (context, index) {
                            return ChatUserCard(
                              user: _isSearching
                                  ? _searchList[index]
                                  : _usersData[index],
                            );
                          });
                    } else {
                      return Center(
                          child: Text(
                        "No Connections Found!",
                        style: TextStyle(fontSize: 17, color: Colors.black54),
                      ));
                    }
                }
              }),
          floatingActionButton: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FloatingActionButton(
                onPressed: () {},
                child: Icon(
                  Icons.message_rounded,
                ),
              )),
        ),
      ),
    );
  }
}
