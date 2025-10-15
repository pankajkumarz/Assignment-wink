import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/user.dart';
import '../../../domain/usecases/auth/get_current_user.dart';
import '../../../domain/usecases/auth/sign_in_with_email.dart';
import '../../../domain/usecases/auth/sign_out.dart';
import '../../../domain/usecases/auth/sign_up_with_email.dart';
import '../../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required SignInWithEmail signInWithEmail,
    required SignUpWithEmail signUpWithEmail,
    required SignOut signOut,
    required GetCurrentUser getCurrentUser,
    required AuthRepository authRepository,
  })  : _signInWithEmail = signInWithEmail,
        _signUpWithEmail = signUpWithEmail,
        _signOut = signOut,
        _getCurrentUser = getCurrentUser,
        _authRepository = authRepository,
        super(const AuthInitial()) {
    on<AuthEvent>((event, emit) {
      emit(const AuthLoading());
    });
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthCheckRequested>(_onCheckRequested);

    // Listen to auth state changes
    _authStateSubscription = _authRepository.authStateChanges.listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  final SignInWithEmail _signInWithEmail;
  final SignUpWithEmail _signUpWithEmail;
  final SignOut _signOut;
  final GetCurrentUser _getCurrentUser;
  final AuthRepository _authRepository;

  StreamSubscription<User?>? _authStateSubscription;

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _signInWithEmail(
      SignInWithEmailParams(
        email: event.email,
        password: event.password,
      ),
    );

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _signUpWithEmail(
      SignUpWithEmailParams(
        email: event.email,
        password: event.password,
        name: event.name,
        age: event.age,
        city: event.city,
        phone: event.phone,
      ),
    );

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthSuccess(user)),
    );
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _signOut();

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(const AuthInitial()),
    );
  }

  void _onUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.user != null) {
      emit(AuthSuccess(event.user!));
    } else {
      emit(const AuthInitial());
    }
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await _getCurrentUser();

    result.fold(
      (failure) => emit(const AuthInitial()),
      (user) {
        if (user != null) {
          emit(AuthSuccess(user));
        } else {
          emit(const AuthInitial());
        }
      },
    );
  }
}