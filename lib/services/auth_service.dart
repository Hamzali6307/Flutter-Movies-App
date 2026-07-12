import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      debugPrint("AuthService: Firebase not initialized: $e");
      return null;
    }
  }

  Stream<User?> get user {
    final auth = _auth;
    if (auth == null) return Stream.value(null);
    return auth.authStateChanges();
  }
  
  User? get currentUser => _auth?.currentUser;

  Future<UserCredential?> signUp(String email, String password) async {
    final auth = _auth;
    if (auth == null) return null;
    try {
      return await auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<UserCredential?> login(String email, String password) async {
    final auth = _auth;
    if (auth == null) return null;
    try {
      return await auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<void> logout() async {
    await _auth?.signOut();
  }
}
