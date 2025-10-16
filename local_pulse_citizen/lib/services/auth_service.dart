import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get current user
  static User? get currentUser => _auth.currentUser;
  static bool get isLoggedIn => currentUser != null;
  
  // Sign up with email and password
  static Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String city,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        final userModel = UserModel(
          id: credential.user!.uid,
          email: email,
          displayName: name,
          phone: phone,
          city: city,
          role: 'citizen',
          createdAt: DateTime.now(),
        );
        
        // Save user data to Firestore
        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userModel.toMap());
        
        return userModel;
      }
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
    return null;
  }
  
  // Sign in with email and password
  static Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        // Get user data from Firestore
        final doc = await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .get();
        
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          return UserModel.fromMap(data);
        } else {
          // If user document doesn't exist, create one with basic info
          final userModel = UserModel(
            id: credential.user!.uid,
            email: credential.user!.email ?? email,
            displayName: credential.user!.displayName ?? 'User',
            phone: '',
            city: '',
            role: 'citizen',
            createdAt: DateTime.now(),
          );
          
          // Save user data to Firestore
          await _firestore
              .collection('users')
              .doc(credential.user!.uid)
              .set(userModel.toMap());
          
          return userModel;
        }
      }
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
    return null;
  }
  
  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // Get current user data
  static Future<UserModel?> getCurrentUserData() async {
    if (currentUser != null) {
      try {
        final doc = await _firestore
            .collection('users')
            .doc(currentUser!.uid)
            .get();
        
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          return UserModel.fromMap(data);
        } else {
          // If user document doesn't exist, create one with basic info
          final userModel = UserModel(
            id: currentUser!.uid,
            email: currentUser!.email ?? '',
            displayName: currentUser!.displayName ?? 'User',
            phone: '',
            city: '',
            role: 'citizen',
            createdAt: DateTime.now(),
          );
          
          // Save user data to Firestore
          await _firestore
              .collection('users')
              .doc(currentUser!.uid)
              .set(userModel.toMap());
          
          return userModel;
        }
      } catch (e) {
        print('Get user data error: $e');
      }
    }
    return null;
  }
}