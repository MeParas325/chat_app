import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: Icon(CupertinoIcons.home),
          title: Text("Our Chat"),
          actions: [
            IconButton(onPressed: () {
              
            }, icon: Icon(Icons.search)),
            IconButton(onPressed: () {
              
            }, icon: Icon(Icons.more_vert)),
          ]),

          floatingActionButton: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FloatingActionButton(onPressed: () {
              

              
            }, child:Icon(Icons.add_comment_rounded)),
          ),
    );
  }
}
