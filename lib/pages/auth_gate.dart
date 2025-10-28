import 'package:expenses_app/components/loading_screen.dart';
import 'package:expenses_app/pages/home.dart';
import 'package:expenses_app/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: LoadingScreen()));
        }

        // User is signed in
        if (snapshot.hasData) {
          return Home();
        }

        // User is NOT signed in
        return LoginPage();
      },
    );
  }
}
