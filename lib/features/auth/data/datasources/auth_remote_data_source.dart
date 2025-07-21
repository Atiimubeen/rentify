import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rentify/core/error/exceptions.dart';
import 'package:rentify/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  });
  Future<UserModel> signIn({required String email, required String password});
  Future<UserModel> signInWithGoogle();
  Future<void> signOut();
  Future<auth.User?> getCurrentUser();
  Future<UserModel> getUserData(String uid);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    required auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore,
       _googleSignIn = googleSignIn;

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw ServerException('Sign up failed, please try again.');
      }
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final userModel = UserModel(
        uid: firebaseUser.uid,
        email: email,
        name: name,
        role: role,
        fcmToken: fcmToken,
      );
      await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .set(userModel.toFirestore());
      return userModel;
    } on auth.FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'An unknown error occurred.');
    }
  }

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw ServerException('Sign in failed, please try again.');
      }
      final fcmToken = await FirebaseMessaging.instance.getToken();
      await _firestore.collection('users').doc(firebaseUser.uid).update({
        'fcmToken': fcmToken,
      });
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (!doc.exists) {
        throw ServerException('User data not found.');
      }
      return UserModel.fromFirestore(doc);
    } on auth.FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'An unknown error occurred.');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn
          .authenticate();
      if (googleUser == null) {
        throw ServerException('Google sign in was cancelled.');
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw ServerException('Failed to sign in with Google.');
      }
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final docRef = _firestore.collection('users').doc(firebaseUser.uid);
      final doc = await docRef.get();
      if (!doc.exists) {
        final newUser = UserModel(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName,
          email: firebaseUser.email,
          photoUrl: firebaseUser.photoURL,
          role: null,
          fcmToken: fcmToken,
        );
        await docRef.set(newUser.toFirestore());
        return newUser;
      } else {
        await docRef.update({'fcmToken': fcmToken});
        final updatedDoc = await docRef.get();
        return UserModel.fromFirestore(updatedDoc);
      }
    } on auth.FirebaseAuthException catch (e) {
      throw ServerException(e.message ?? 'An unknown Firebase error occurred.');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      final isGoogleUser =
          _firebaseAuth.currentUser?.providerData.any(
            (userInfo) => userInfo.providerId == 'google.com',
          ) ??
          false;
      if (isGoogleUser) {
        await _googleSignIn.signOut();
      }
      await _firebaseAuth.signOut();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<auth.User?> getCurrentUser() async {
    return _firebaseAuth.currentUser;
  }

  @override
  Future<UserModel> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      } else {
        throw ServerException('User data not found.');
      }
    } on FirebaseException catch (e) {
      throw ServerException(e.message ?? 'Failed to get user data.');
    }
  }
}
