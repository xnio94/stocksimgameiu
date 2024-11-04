import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user's profile containing personal information.
class UserProfile {
  /// The unique user ID from Firebase Authentication.
  final String uid;

  /// The user's first name.
  final String firstName;

  /// The user's last name.
  final String lastName;

  /// The user's email address.
  final String email;

  /// A unique identifier for the user.
  final int uniqueId;

  /// Constructs a [UserProfile] with the required fields.
  UserProfile({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.uniqueId,
  });

  /// Converts the [UserProfile] instance to a map for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'unique_id': uniqueId,
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  /// Creates a [UserProfile] instance from a Firestore map and UID.
  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      firstName: map['first_name'] ?? '',
      lastName: map['last_name'] ?? '',
      email: map['email'] ?? '',
      uniqueId: map['unique_id'] ?? 0,
    );
  }
}