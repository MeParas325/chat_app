import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import 'package:untitled/main.dart';
import 'package:untitled/screens/home_screen.dart';

import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 2000), () {
      // disable full mode
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: mq.height * 0.25,
            width: mq.width * 0.5,
            right: mq.width * 0.25,
            child: Image.asset("assets/icon/icon.png"),
          ),
          Positioned(
            bottom: mq.height * 0.15,
            width: mq.width,
            child: Text(
              "Made in India with 🧡",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16, letterSpacing: 0.5, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
