import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignInRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AuthSignOutRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;

  const AuthSuccess({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
  }

  void _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    // TODO: Implement auth check logic
    await Future.delayed(const Duration(seconds: 1));
    emit(const AuthFailure(message: 'Not authenticated'));
  }

  void _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    // TODO: Implement sign in logic
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock user for now
    final user = User(
      id: 'mock-id',
      email: event.email,
      name: 'Authority User',
      age: 30,
      city: 'New Delhi',
      role: 'authority',
      preferences: const UserPreferences(
        language: 'en',
        theme: 'system',
        notifications: NotificationSettings(
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
    
    emit(AuthSuccess(user: user));
  }

  void _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    // TODO: Implement sign out logic
    await Future.delayed(const Duration(seconds: 1));
    emit(AuthInitial());
  }
}