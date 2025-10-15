import 'package:dartz/dartz.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/utils/typedef.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  ResultFuture<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await _remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(result);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  ResultFuture<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required int age,
    required String city,
    String? phone,
  }) async {
    try {
      final result = await _remoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        age: age,
        city: city,
        phone: phone,
      );
      return Right(result);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  ResultFuture<User> signInWithGoogle() async {
    try {
      final result = await _remoteDataSource.signInWithGoogle();
      return Right(result);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  ResultFuture<User> signInWithFacebook() async {
    // TODO: Implement Facebook sign in
    return const Left(AuthFailure('Facebook sign in not implemented yet'));
  }

  @override
  ResultVoid signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  ResultVoid resetPassword({required String email}) async {
    try {
      await _remoteDataSource.resetPassword(email: email);
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  ResultFuture<User?> getCurrentUser() async {
    try {
      final result = await _remoteDataSource.getCurrentUser();
      return Right(result);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return _remoteDataSource.authStateChanges;
  }

  @override
  ResultVoid updateUserProfile({required User user}) async {
    try {
      await _remoteDataSource.updateUserProfile(
        user: UserModel.fromEntity(user),
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  ResultVoid deleteUserAccount() async {
    try {
      await _remoteDataSource.deleteUserAccount();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  ResultVoid setCustomClaims({
    required String userId,
    required Map<String, dynamic> claims,
  }) async {
    try {
      await _remoteDataSource.setCustomClaims(
        userId: userId,
        claims: claims,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  ResultFuture<Map<String, dynamic>> getUserClaims() async {
    try {
      final result = await _remoteDataSource.getUserClaims();
      return Right(result);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}