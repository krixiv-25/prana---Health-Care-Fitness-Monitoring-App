import 'package:flutter/material.dart';
import 'package:kenko/activity.dart';
import 'package:kenko/foodwater.dart';
import 'package:kenko/home.dart';
import 'package:kenko/login.dart';
import 'package:kenko/mappage.dart';
import 'package:kenko/profile.dart';
import 'package:kenko/signup.dart';
import 'package:kenko/mental.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'heightweight.dart';
import 'dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: (Login()),
      routes: {
        '/signup': (context) => Signup(),
        '/login': (context) => Login(),
        '/home': (context) => Home(),
        '/profile': (context) => Profile(),
        '/food&water': (context) => FoodWaterLog(),
        '/activity': (context) => ActivityLog(),
        '/map': (context) => FreeMapScreen(),
        '/mental': (context) => MentalPage(),
        '/heightweight': (context) => HeightWeight(),
        '/dashboard': (context) => Dashboard(),
      },
    ),
  );
}
