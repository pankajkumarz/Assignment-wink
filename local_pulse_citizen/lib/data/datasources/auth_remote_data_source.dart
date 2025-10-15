import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/error/exceptions.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required int age,
    required String city,
    String? phone,
  });

  Future<UserModel> signInWithGoogle();

  Future<void> signOut();

  Future<void> resetPassword({required String email});

  Future<UserModel?> getCurrentUser();

  Stream<UserModel?> get authStateChanges;

  Future<void> updateUserProfile({required UserModel user});

  Future<void> deleteUserAccount();

  Future<void> setCustomClaims({
    required String userId,
    required Map<String, dynamic> claims,
  });

  Future<Map<String, dynamic>> getUserClaims();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({
    required firebase_auth.FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        _googleSignIn = googleSignIn;

  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException('Sign in failed - no user returned');
      }

      // Get user data from Firestore
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw const AuthException('User profile not found');
      }

      return UserModel.fromMap(userDoc.data()!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign in failed');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required int age,
    required String city,
    String? phone,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw const AuthException('Sign up failed - no user returned');
      }

      // Create user profile in Firestore
      final userModel = UserModel(
        id: user.uid,
        email: email,
        name: name,
        phone: phone,
        age: age,
        city: city,
        role: AppConstants.roleCitizen,
        preferences: const UserPreferencesModel(
          language: AppConstants.languageEnglish,
          theme: AppConstants.themeSystem,
          notifications: NotificationSettingsModel(
            pushEnabled: true,
            emailEnabled: true,
            whatsappEnabled: false,
            statusUpdates: true,
            alerts: true,
          ),
          whatsappEnabled: false,
        ),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toMap());

      // Update Firebase Auth display name
      await user.updateDisplayName(name);

      return userModel;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Sign up failed');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Google sign in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw const AuthException('Google sign in failed - no user returned');
      }

      // Check if user profile exists
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data()!);
      } else {
        // Create new user profile for Google sign in
        final userModel = UserModel(
          id: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? 'Google User',
          phone: user.phoneNumber,
          age: 25, // Default age - user will need to update
          city: '', // User will need to select city
          role: AppConstants.roleCitizen,
          preferences: const UserPreferencesModel(
            language: AppConstants.languageEnglish,
            theme: AppConstants.themeSystem,
            notifications: NotificationSettingsModel(
              pushEnabled: true,
              emailEnabled: true,
              whatsappEnabled: false,
              statusUpdates: true,
              alerts: true,
            ),
            whatsappEnabled: false,
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(userModel.toMap());

        return userModel;
      }
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> resetPassword({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Password reset failed');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) return null;

      return UserModel.fromMap(userDoc.data()!);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;

      try {
        final userDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .get();

        if (!userDoc.exists) return null;

        return UserModel.fromMap(userDoc.data()!);
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Future<void> updateUserProfile({required UserModel user}) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .update(user.copyWith(updatedAt: DateTime.now()).toMap());
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> deleteUserAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException('No user signed in');
      }

      // Delete user data from Firestore
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .delete();

      // Delete Firebase Auth account
      await user.delete();
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> setCustomClaims({
    required String userId,
    required Map<String, dynamic> claims,
  }) async {
    // This would typically be done via Cloud Functions
    // For now, we'll store claims in Firestore
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({'customClaims': claims});
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>> getUserClaims() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthException('No user signed in');
      }

      final idTokenResult = await user.getIdTokenResult();
      return idTokenResult.claims ?? {};
    } catch (e) {
      throw AuthException(e.toString());
    }
  }
}