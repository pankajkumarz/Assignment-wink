import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/datasources/issue_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/issue_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/issue_repository.dart';
import '../../domain/usecases/auth/get_current_user.dart';
import '../../domain/usecases/auth/sign_in_with_email.dart';
import '../../domain/usecases/auth/sign_out.dart';
import '../../domain/usecases/auth/sign_up_with_email.dart';
import '../../domain/usecases/issues/create_issue.dart';
import '../../domain/usecases/issues/get_user_issues.dart';
import '../../domain/usecases/issues/get_nearby_issues.dart';
import '../../domain/usecases/issues/watch_public_issues.dart';
import '../../presentation/bloc/auth/auth_bloc.dart';
import '../../presentation/bloc/issues/issues_bloc.dart';
import '../../presentation/bloc/theme/theme_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External dependencies
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
  sl.registerLazySingleton(() => GoogleSignIn());

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
      googleSignIn: sl(),
    ),
  );

  sl.registerLazySingleton<IssueRemoteDataSource>(
    () => IssueRemoteDataSourceImpl(
      firestore: sl(),
      storage: sl(),
    ),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<IssueRepository>(
    () => IssueRepositoryImpl(sl()),
  );

  // Use cases - Auth
  sl.registerLazySingleton(() => SignInWithEmail(sl()));
  sl.registerLazySingleton(() => SignUpWithEmail(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  // Use cases - Issues
  sl.registerLazySingleton(() => CreateIssue(sl()));
  sl.registerLazySingleton(() => GetUserIssues(sl()));
  sl.registerLazySingleton(() => GetNearbyIssues(sl()));
  sl.registerLazySingleton(() => WatchPublicIssues(sl()));

  // BLoCs
  sl.registerFactory(
    () => AuthBloc(
      signInWithEmail: sl(),
      signUpWithEmail: sl(),
      signOut: sl(),
      getCurrentUser: sl(),
      authRepository: sl(),
    ),
  );

  sl.registerFactory(
    () => IssuesBloc(
      createIssue: sl(),
      getUserIssues: sl(),
      getNearbyIssues: sl(),
      watchPublicIssues: sl(),
      issueRepository: sl(),
    ),
  );

  sl.registerFactory(() => ThemeBloc());
}