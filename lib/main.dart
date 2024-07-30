import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'Auth.dart';
import 'login.dart';
import 'forgot_pass.dart';
import 'signup.dart';
import 'home.dart';
import 'tasks.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(apiKey: "AIzaSyCP7907QkYCt6l8SoYqXxfM0-hoYGQE1gY", authDomain: "loginflt.firebaseapp.com", projectId: "loginflt", storageBucket: "loginflt.appspot.com", messagingSenderId: "525253198028", appId: "1:525253198028:web:944341359d4730e089c269", measurementId: "G-7Z4ZJ3ZH02"),
  );
  tz.initializeTimeZones();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const Auth(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/forgot_password': (context) => const ForgotPasswordPage(),
        '/home': (context) => const HomeScreen(),
        '/tasks': (context) => const TaskScreen(),
      },
    );
  }
}
