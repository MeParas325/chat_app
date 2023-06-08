import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:untitled/themes/theme_provider.dart';
import 'firebase_options.dart';

import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';


late Size mq;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // enable full screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // set device orientation
  SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((value) async {
    // initialize firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    var result = await FlutterNotificationChannel.registerNotificationChannel(
      description: 'For showing message notification',
      id: 'chats',
      importance: NotificationImportance.IMPORTANCE_HIGH,
      name: 'Chats',
    );
    log('\nNotification channel result: ${result}');
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: MyThemes.lightTheme,
      themeMode: ThemeMode.system,
      darkTheme: MyThemes.darkTheme,
      home: SplashScreen(),
    );
  }
}
