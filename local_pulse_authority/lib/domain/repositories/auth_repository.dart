import '../../core/utils/typedef.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  // Authentication methods
  ResultFuture<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  ResultFuture<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required int age,
    required String city,
    String? phone,
  });

  ResultFuture<User> signInWithGoogle();

  ResultFuture<User> signInWithFacebook();

  ResultVoid signOut();

  ResultVoid resetPassword({required String email});

  // User session management
  ResultFuture<User?> getCurrentUser();

  Stream<User?> get authStateChanges;

  // User profile management
  ResultVoid updateUserProfile({required User user});

  ResultVoid deleteUserAccount();

  // Role and permissions
  ResultVoid setCustomClaims({
    required String userId,
    required Map<String, dynamic> claims,
  });

  ResultFuture<Map<String, dynamic>> getUserClaims();
}