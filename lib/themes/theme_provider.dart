import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyThemes{

  static final lightTheme = ThemeData(
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.white),
      iconTheme: IconThemeData(color: Colors.black),
      elevation: 1,
      centerTitle: true,
      titleTextStyle: TextStyle(
          color: Colors.black, fontWeight: FontWeight.normal, fontSize: 20),
    ),
    backgroundColor: Colors.white,

  );

  static final darkTheme = ThemeData(
    appBarTheme: AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.black),
      iconTheme: IconThemeData(color: Colors.white),
      elevation: 1,
      centerTitle: true,
      titleTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.normal, fontSize: 20)
    ),
    scaffoldBackgroundColor: Colors.grey.shade900,
    colorScheme: ColorScheme.dark(),
    backgroundColor: Colors.black

  );
}