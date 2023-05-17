import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  List<ChatUser> usersData = [];

  @override
  void initState() {
    APIs.getSelfInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: Icon(CupertinoIcons.home),
          title: Text("Our Chat"),
          actions: [
            IconButton(onPressed: () {}, icon: Icon(Icons.search)),
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

                usersData = data
                        ?.map((user) => ChatUser.fromJson(user.data()))
                        .toList() ??
                    [];
                // log('Data: ${usersData}');

                if (usersData.isNotEmpty) {
                  return ListView.builder(
                      physics: BouncingScrollPhysics(),
                      itemCount: usersData.length,
                      itemBuilder: (context, index) {
                        return ChatUserCard(
                          user: usersData[index],
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
        child: FloatingActionButton.extended(
          backgroundColor: Colors.red,
          onPressed: () async {
            await APIs.auth.signOut();
            await GoogleSignIn().signOut();
          },
          icon: Icon(Icons.logout),
          label: Text("logout"),
        ),
      ),
    );
  }
}
