import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:registration_with_firebase_demo/constants/routes.dart';
import 'package:registration_with_firebase_demo/auth/sign_in.dart';
import 'package:registration_with_firebase_demo/auth/sign_up.dart';
import 'package:registration_with_firebase_demo/crud/add_notes.dart';
import 'package:registration_with_firebase_demo/home/home_screen.dart';
import 'package:registration_with_firebase_demo/test.dart';

bool isLogin = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    final notification = message.notification;
    if (notification != null) {
      print('Background message: ${notification.body}');
    } else {
      print('Background message received with no notification payload');
    }
  }

  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    isLogin = true;
  } else {
    isLogin = false;
  }
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.instance.getInitialMessage();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            color: Theme.of(context).scaffoldBackgroundColor,
            fontSize: 38,
            fontWeight: FontWeight.w900,
          ),
        ),
        primaryColor: Colors.blue,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.blue,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 24),
        ),
        scaffoldBackgroundColor: Colors.white,
        actionIconTheme: ActionIconThemeData(
          backButtonIconBuilder: (context) => Icon(Icons.arrow_back_ios),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: Colors.blue[900]),
        ),
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        Routes.signIn.toString(): (_) => SignInScreen(),
        Routes.signUp.toString(): (_) => SignUpScreen(),
        Routes.home.toString(): (_) => HomeScreen(),
        Routes.addNotes.toString(): (_) => AddNotes(),
      },
      // home: isLogin ? HomeScreen() : SignInScreen(),
      home: MyWidget(),
    );
  }
}
