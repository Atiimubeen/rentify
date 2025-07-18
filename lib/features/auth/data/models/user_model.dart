import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    as auth; // Alias to avoid name conflict
import 'package:rentify/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  final String? fcmToken;
  const UserModel({
    required super.uid,
    super.email,
    super.name,
    super.photoUrl,
    super.role,
    this.fcmToken,
  });

  // Factory to create a UserModel from a Firebase Auth User
  factory UserModel.fromFirebaseAuth(auth.User firebaseUser) {
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      name: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
    );
  }

  // Factory to create a UserModel from a Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      fcmToken: data['fcmToken'],
      uid: doc.id,
      email: data['email'],
      name: data['name'],
      photoUrl: data['photoUrl'],
      role: data['role'],
    );
  }

  // Method to convert UserModel to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'role': role,
      'fcmToken': fcmToken,
    };
  }

  // Method to create a copy with updated values
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? photoUrl,
    String? role,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
    );
  }
}
