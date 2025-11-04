import 'package:expenses_app/components/loading_screen.dart';
import 'package:expenses_app/pages/home.dart';
import 'package:expenses_app/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkFirebaseInitialization(),
      builder: (context, initSnapshot) {
        // Check if Firebase initialization failed
        if (initSnapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: LoadingScreen()));
        }

        if (initSnapshot.hasError || initSnapshot.data == false) {
          // Firebase not initialized or offline - show error message
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Unable to connect to Firebase',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please check your internet connection and try again.',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Force rebuild to retry
                        (context as Element).markNeedsBuild();
                      },
                      icon: Icon(Icons.refresh),
                      label: Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Firebase is initialized, proceed with auth check
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // Handle stream errors (e.g., network issues)
            if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text(
                          'Authentication Error',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

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
      },
    );
  }

  Future<bool> _checkFirebaseInitialization() async {
    try {
      // Check if Firebase is initialized
      await Firebase.initializeApp();
      return true;
    } catch (e) {
      // Firebase already initialized or initialization failed
      try {
        // Try to access Firebase to see if it's working
        Firebase.app();
        return true;
      } catch (e) {
        print('Firebase not available: $e');
        return false;
      }
    }
  }
}
