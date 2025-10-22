import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static FirebaseAuth auth = FirebaseAuth.instance;

  static User? getCurrentUser() {
    return auth.currentUser;
  }

  static String? getCurrentUserName() {
    return auth.currentUser?.displayName;
  }

  Future<void> signUp(String email, String password, String name) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update the user's display name
      await userCredential.user?.updateDisplayName(name);
      await userCredential.user?.reload();
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (e) {
      print('Sign out error: $e');
      rethrow;
    }
  }
}
