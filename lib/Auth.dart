import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'login.dart';

class Auth extends StatelessWidget {
  const Auth({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
