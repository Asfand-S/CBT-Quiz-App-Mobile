import 'package:flutter/material.dart';

Color myTealShade = Colors.teal.shade600;

ThemeData appTheme = ThemeData(
  primarySwatch: Colors.teal,
  progressIndicatorTheme: ProgressIndicatorThemeData(color: Colors.teal),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.teal.shade500,
    foregroundColor: Colors.white,
    centerTitle: true,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 24,
    ),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.teal.shade500,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
          backgroundColor: Colors.teal.shade500,
          foregroundColor: Colors.white,
          padding: EdgeInsets.fromLTRB(24, 8, 24, 8))),
);

BoxDecoration gradientBackground = BoxDecoration(
  borderRadius: BorderRadius.circular(16),
  gradient: LinearGradient(
    colors: [
      Colors.teal.shade300,
      myTealShade,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  boxShadow: [
    BoxShadow(
      color: Colors.teal.shade200.withOpacity(0.4),
      blurRadius: 12,
      offset: const Offset(0, 3),
    ),
  ],
);
