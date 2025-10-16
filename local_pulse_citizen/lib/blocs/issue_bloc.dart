import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/issue_model.dart';
import '../models/location_model.dart';
import '../services/issue_service.dart';

// Events
abstract class IssueEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class IssueCreateRequested extends IssueEvent {
  final String title;
  final String description;
  final String category;
  final String priority;
  final LocationModel location;
  final List<File>? images;

  IssueCreateRequested({
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.location,
    this.images,
  });

  @override
  List<Object?> get props => [title, description, category, priority, location, images];
}

class UserIssuesRequested extends IssueEvent {}

class NearbyIssuesRequested extends IssueEvent {
  final double latitude;
  final double longitude;

  NearbyIssuesRequested({required this.latitude, required this.longitude});

  @override
  List<Object> get props => [latitude, longitude];
}

class IssueDetailsRequested extends IssueEvent {
  final String issueId;

  IssueDetailsRequested({required this.issueId});

  @override
  List<Object> get props => [issueId];
}

// States
abstract class IssueState extends Equatable {
  @override
  List<Object?> get props => [];
}

class IssueInitial extends IssueState {}

class IssueLoading extends IssueState {}

class IssueCreateSuccess extends IssueState {
  final String issueId;

  IssueCreateSuccess({required this.issueId});

  @override
  List<Object> get props => [issueId];
}

class UserIssuesLoaded extends IssueState {
  final List<IssueModel> issues;

  UserIssuesLoaded({required this.issues});

  @override
  List<Object> get props => [issues];
}

class NearbyIssuesLoaded extends IssueState {
  final List<IssueModel> issues;

  NearbyIssuesLoaded({required this.issues});

  @override
  List<Object> get props => [issues];
}

class IssueDetailsLoaded extends IssueState {
  final IssueModel issue;

  IssueDetailsLoaded({required this.issue});

  @override
  List<Object> get props => [issue];
}

class IssueError extends IssueState {
  final String message;

  IssueError({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class IssueBloc extends Bloc<IssueEvent, IssueState> {
  IssueBloc() : super(IssueInitial()) {
    on<IssueCreateRequested>(_onIssueCreateRequested);
    on<UserIssuesRequested>(_onUserIssuesRequested);
    on<NearbyIssuesRequested>(_onNearbyIssuesRequested);
    on<IssueDetailsRequested>(_onIssueDetailsRequested);
  }

  Future<void> _onIssueCreateRequested(
    IssueCreateRequested event,
    Emitter<IssueState> emit,
  ) async {
    emit(IssueLoading());
    
    try {
      final issueId = await IssueService.createIssue(
        title: event.title,
        description: event.description,
        category: event.category,
        priority: event.priority,
        location: event.location,
        images: event.images,
      );
      
      emit(IssueCreateSuccess(issueId: issueId));
    } catch (e) {
      emit(IssueError(message: e.toString()));
    }
  }

  Future<void> _onUserIssuesRequested(
    UserIssuesRequested event,
    Emitter<IssueState> emit,
  ) async {
    emit(IssueLoading());
    
    try {
      final issues = await IssueService.getUserIssues();
      emit(UserIssuesLoaded(issues: issues));
    } catch (e) {
      emit(IssueError(message: e.toString()));
    }
  }

  Future<void> _onNearbyIssuesRequested(
    NearbyIssuesRequested event,
    Emitter<IssueState> emit,
  ) async {
    emit(IssueLoading());
    
    try {
      final issues = await IssueService.getNearbyIssues(
        latitude: event.latitude,
        longitude: event.longitude,
      );
      emit(NearbyIssuesLoaded(issues: issues));
    } catch (e) {
      emit(IssueError(message: e.toString()));
    }
  }

  Future<void> _onIssueDetailsRequested(
    IssueDetailsRequested event,
    Emitter<IssueState> emit,
  ) async {
    emit(IssueLoading());
    
    try {
      final issue = await IssueService.getIssueById(event.issueId);
      if (issue != null) {
        emit(IssueDetailsLoaded(issue: issue));
      } else {
        emit(IssueError(message: 'Issue not found'));
      }
    } catch (e) {
      emit(IssueError(message: e.toString()));
    }
  }
}