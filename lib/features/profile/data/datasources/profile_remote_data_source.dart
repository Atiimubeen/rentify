import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rentify/core/error/exceptions.dart';
import 'package:rentify/features/auth/data/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getUserProfile(String uid);
  Future<void> updateUserProfile(UserModel user);
  Future<String> uploadProfilePicture(File image, String uid);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  ProfileRemoteDataSourceImpl({required this.firestore, required this.storage});

  @override
  Future<UserModel> getUserProfile(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      } else {
        throw ServerException('User profile not found.');
      }
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get profile.');
    }
  }

  @override
  Future<void> updateUserProfile(UserModel user) async {
    try {
      await firestore.collection('users').doc(user.uid).update({
        'name': user.name,
        'phone': user.phone,
      });
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to update profile.');
    }
  }

  @override
  Future<String> uploadProfilePicture(File image, String uid) async {
    try {
      final ref = storage.ref().child('profile_pictures').child(uid);
      await ref.putFile(image);
      final url = await ref.getDownloadURL();

      // Update the photoUrl in the user's document
      await firestore.collection('users').doc(uid).update({'photoUrl': url});

      return url;
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to upload image.');
    }
  }
}
