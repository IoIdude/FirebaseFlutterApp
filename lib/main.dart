import 'package:firebase_app/create_post.dart';
import 'package:firebase_app/edit_post.dart';
import 'package:firebase_app/home.dart';
import 'package:firebase_app/registration.dart';
import 'package:firebase_app/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'auth.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FirebaseApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: 'auth',
      routes: {
        'auth': (context) => AuthPage(),
        'register': (context) => RegisterPage(),
        'home': (context) => HomePage(),
        'profile': (context) => UserProfile(),
        'posts': (context) => CreatePostPage(),
        'editNote': (context) => EditPostPage()
      },
    );
  }
}
