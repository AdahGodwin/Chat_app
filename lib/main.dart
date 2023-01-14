import 'package:chat_app/screens/auth_screen.dart';
import 'package:chat_app/screens/chat_list_screen.dart';
import 'package:chat_app/screens/home_screen.dart';
import 'package:chat_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';

import './screens/chat_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Future<FirebaseApp> initialisation = Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return FutureBuilder(
      future: initialisation,
      builder: (context, snapshot) => MaterialApp(
        title: 'Flutter Chat',
        theme: ThemeData(
          primarySwatch: Colors.pink,
          backgroundColor: Colors.pink,
          accentColor: Colors.deepPurple,
          accentColorBrightness: Brightness.dark,
          buttonTheme: ButtonTheme.of(context).copyWith(
            buttonColor: Colors.pink,
            textTheme: ButtonTextTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        home: snapshot.connectionState == ConnectionState.waiting
            ? const SplashScreen()
            : StreamBuilder(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (context, appSnapshot) {
                  if (appSnapshot.connectionState == ConnectionState.waiting) {
                    return const SplashScreen();
                  } else if (appSnapshot.hasData) {
                    return const HomeScreen();
                  } else {
                    return const AuthScreen();
                  }
                },
              ),
        routes: {
          ChatListScreen.routeName: (context) => const ChatListScreen(),
          ChatScreen.routeName: (context) => const ChatScreen(),
        },
      ),
    );
  }
}
