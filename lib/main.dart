import 'package:flutter/material.dart';

import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';

import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

late Size mq;

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          iconTheme: IconThemeData(color: Colors.black),
          elevation: 1,
          centerTitle: true,
          titleTextStyle: TextStyle(
              color: Colors.black, fontWeight: FontWeight.normal, fontSize: 20),
          backgroundColor: Colors.white,
        ),
      ),
      home: LoginScreen(),
    );
  }
}
