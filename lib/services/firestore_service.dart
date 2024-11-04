import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

/// Service for interacting with Firestore database.
class FirestoreService {
  /// Instance of FirebaseFirestore.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates a user profile document in Firestore.
  ///
  /// Throws an [Exception] if the operation fails.
  Future<void> createUserProfile(UserProfile profile) async {
    try {
      DocumentReference docRef =
          _firestore.collection('users').doc(profile.uid);
      await docRef.set(profile.toMap());
    } catch (e) {
      throw Exception('Failed to create user profile: ${e.toString()}');
    }
  }

  /// Retrieves a user profile from Firestore based on UID.
  ///
  /// Returns [UserProfile] if found, otherwise null.
  /// Throws an [Exception] if the operation fails.
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserProfile.fromMap(
            doc.data() as Map<String, dynamic>, uid);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user profile: ${e.toString()}');
    }
  }

  /// Generates a unique ID for a new user by incrementing a counter in Firestore.
  ///
  /// Throws an [Exception] if the operation fails.
  Future<int> generateUniqueId() async {
    try {
      DocumentReference counterRef =
          _firestore.collection('counters').doc('user_id_counter');
      DocumentSnapshot counterDoc = await counterRef.get();

      if (counterDoc.exists) {
        int currentId = counterDoc['current_id'] ?? 10000;
        int newId = currentId + 1;
        await counterRef.update({'current_id': newId});
        return newId;
      } else {
        // Initialize counter if it doesn't exist.
        await counterRef.set({'current_id': 10000});
        return 10001;
      }
    } catch (e) {
      throw Exception('Failed to generate unique ID: ${e.toString()}');
    }
  }
}