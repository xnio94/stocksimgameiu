import 'package:firebase_auth/firebase_auth.dart';

/// Service for handling authentication-related operations.
class AuthService {
  /// Instance of FirebaseAuth.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Retrieves the current authenticated user.
  User? get currentUser => _auth.currentUser;

  /// Signs in a user with email and password.
  ///
  /// Throws an [AuthException] if authentication fails.
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Authentication failed.');
    }
  }

  /// Signs up a new user with email and password.
  ///
  /// Throws an [AuthException] if registration fails.
  Future<UserCredential> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Registration failed.');
    }
  }

  /// Signs out the current user.
  ///
  /// Throws an [Exception] if sign-out fails.
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }
}

/// Custom exception for authentication errors.
class AuthException implements Exception {
  /// The error message.
  final String message;

  AuthException({required this.message});
}