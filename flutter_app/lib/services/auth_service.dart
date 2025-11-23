import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      notifyListeners();
    });
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        debugPrint('Sign in error: ${e.message}');
      }
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String role) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        debugPrint('Sign up error: ${e.message}');
      }
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
