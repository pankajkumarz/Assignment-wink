import '../../core/utils/typedef.dart';
import '../entities/user.dart';

abstract class UserRepository {
  // User CRUD operations
  ResultVoid createUser({required User user});

  ResultFuture<User> getUserById({required String userId});

  ResultVoid updateUser({required User user});

  ResultVoid deleteUser({required String userId});

  // User preferences
  ResultVoid updateUserPreferences({
    required String userId,
    required UserPreferences preferences,
  });

  ResultFuture<UserPreferences> getUserPreferences({required String userId});

  // User search and filtering
  ResultFuture<List<User>> getUsersByCity({required String city});

  ResultFuture<List<User>> getUsersByRole({required String role});

  // Profile management
  ResultVoid updateProfileImage({
    required String userId,
    required String imagePath,
  });

  ResultVoid removeProfileImage({required String userId});

  // Account management
  ResultVoid deactivateAccount({required String userId});

  ResultVoid reactivateAccount({required String userId});

  // Data export (GDPR compliance)
  ResultFuture<Map<String, dynamic>> exportUserData({required String userId});
}