import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class UserProfileService {
  static const String _profileKey = 'user_profile';
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Load user profile from local storage and Firestore
  static Future<UserModel?> loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_profileKey);
      
      UserModel? localProfile;
      if (profileJson != null) {
        final profileData = jsonDecode(profileJson);
        localProfile = UserModel.fromJson(profileData);
      }

      // Try to load from Firestore if user is authenticated
      final currentUser = AuthService.currentUser;
      if (currentUser != null) {
        try {
          final doc = await _firestore
              .collection('users')
              .doc(currentUser.uid)
              .get();
          
          if (doc.exists) {
            final firestoreProfile = UserModel.fromJson(doc.data()!);
            // Save to local storage for offline access
            await _saveToLocal(firestoreProfile);
            return firestoreProfile;
          }
        } catch (e) {
          print('Error loading from Firestore: $e');
          // Return local profile if Firestore fails
          return localProfile;
        }
      }

      return localProfile;
    } catch (e) {
      print('Error loading profile: $e');
      return null;
    }
  }

  /// Save user profile to both local storage and Firestore
  static Future<bool> saveProfile(UserModel profile) async {
    try {
      // Save to local storage
      await _saveToLocal(profile);

      // Save to Firestore if user is authenticated
      final currentUser = AuthService.currentUser;
      if (currentUser != null) {
        try {
          await _firestore
              .collection('users')
              .doc(currentUser.uid)
              .set(profile.toJson(), SetOptions(merge: true));
        } catch (e) {
          print('Error saving to Firestore: $e');
          // Continue even if Firestore fails, local save succeeded
        }
      }

      return true;
    } catch (e) {
      print('Error saving profile: $e');
      return false;
    }
  }

  /// Update a specific profile field
  static Future<bool> updateProfileField(String field, dynamic value) async {
    try {
      final currentProfile = await loadProfile();
      if (currentProfile == null) return false;

      // Create updated profile
      final updatedProfile = UserModel(
        id: currentProfile.id,
        email: currentProfile.email,
        displayName: field == 'displayName' ? value : currentProfile.displayName,
        phone: field == 'phone' ? value : currentProfile.phone,
        city: field == 'city' ? value : currentProfile.city,
        profileImageUrl: field == 'profileImageUrl' ? value : currentProfile.profileImageUrl,
        createdAt: currentProfile.createdAt,
        lastLoginAt: currentProfile.lastLoginAt,
      );

      return await saveProfile(updatedProfile);
    } catch (e) {
      print('Error updating profile field: $e');
      return false;
    }
  }

  /// Save profile to local storage
  static Future<void> _saveToLocal(UserModel profile) async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = jsonEncode(profile.toJson());
    await prefs.setString(_profileKey, profileJson);
  }

  /// Clear profile data
  static Future<void> clearProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_profileKey);
    } catch (e) {
      print('Error clearing profile: $e');
    }
  }

  /// Create initial profile for new users
  static Future<UserModel?> createInitialProfile({
    required String email,
    String? displayName,
  }) async {
    try {
      final currentUser = AuthService.currentUser;
      if (currentUser == null) return null;

      final profile = UserModel(
        id: currentUser.uid,
        email: email,
        displayName: displayName ?? email.split('@')[0],
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      final success = await saveProfile(profile);
      return success ? profile : null;
    } catch (e) {
      print('Error creating initial profile: $e');
      return null;
    }
  }
}