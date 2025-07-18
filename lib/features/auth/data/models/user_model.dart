// ... imports
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentify/features/auth/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    super.email,
    super.name,
    super.photoUrl,
    super.role,
    super.phone, // <<< ADD THIS
    super.fcmToken,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'],
      name: data['name'],
      photoUrl: data['photoUrl'],
      role: data['role'],
      phone: data['phone'], // <<< ADD THIS
      fcmToken: data['fcmToken'],
    );
  }

  // Update toFirestore method
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'role': role,
      'phone': phone, // <<< ADD THIS
      'fcmToken': fcmToken,
    };
  }

  // Add copyWith for easy updates
  UserModel copyWith({String? name, String? phone, String? photoUrl}) {
    return UserModel(
      uid: uid,
      email: email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role,
      phone: phone ?? this.phone,
      fcmToken: fcmToken,
    );
  }
}
