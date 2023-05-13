import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter/material.dart';

import 'package:untitled/main.dart';
import '../../helper/dialogs.dart';
import '../home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isAnimate = false;

  @override
  void initState() {
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isAnimate = true;
      });
    });
    super.initState();
  }

  _handleGoogleBtnClick() {
    _signInWithGoogle().then((user) {
      if (user != null) {
        log("User: ${user.user}, ${user.additionalUserInfo}");
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup("google.com");

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      Dialogs.showSnackbar(
          context, 'Something went wrong! Check your Internet connection');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text("Welcome to Our Chat"),
      ),
      body: Stack(
        children: [
          AnimatedPositioned(
            top: mq.height * 0.15,
            width: mq.width * 0.5,
            right: _isAnimate ? mq.width * 0.25 : -mq.width * 0.5,
            duration: Duration(milliseconds: 1000),
            child: Image.asset("assets/icon/icon.png"),
          ),
          Positioned(
            bottom: mq.height * 0.15,
            width: mq.width * 0.8,
            left: mq.width * 0.1,
            height: mq.height * 0.07,
            child: ElevatedButton.icon(
              onPressed: () {
                _handleGoogleBtnClick();
              },
              icon: Image.asset(
                "assets/icon/google.png",
                height: mq.height * 0.03,
              ),
              label: RichText(
                text: TextSpan(
                    style: TextStyle(fontSize: 14, color: Colors.black),
                    children: [
                      TextSpan(text: "Sign in with"),
                      TextSpan(
                        text: " Google",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ]),
              ),
              style: ElevatedButton.styleFrom(
                  elevation: 1,
                  backgroundColor: Color.fromARGB(255, 223, 255, 187),
                  shape: StadiumBorder()),
            ),
          ),
        ],
      ),
    );
  }
}
