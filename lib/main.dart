import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vknder_test/screens/give_info_page.dart';
import 'package:vknder_test/screens/home/home_page.dart';
import 'package:vknder_test/screens/landing_page.dart';
import 'package:vknder_test/screens/login_page.dart';
import 'package:vknder_test/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Optional: Enable Firestore offline persistence for better chat experience
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'vknder_test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Inter',
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        primaryColor: Colors.blueAccent,
        colorScheme: const ColorScheme.dark(
          primary: Colors.blueAccent,
          secondary: Colors.tealAccent,
        ),
      ),
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (ctx) => SplashScreen(),
        LandingPage.routeName: (ctx) => LandingPage(),
        LoginPage.routeName: (ctx) => LoginPage(),
        GiveInfoPage.routeName: (ctx) => GiveInfoPage(),
        HomePage.routeName: (ctx) => HomePage(),
      },
    );
  }
}
