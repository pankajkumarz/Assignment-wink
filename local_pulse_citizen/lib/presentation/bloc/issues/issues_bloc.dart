import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../domain/entities/issue.dart';
import '../../../domain/entities/geo_location.dart';
import '../../../domain/usecases/issues/create_issue.dart';
import '../../../domain/usecases/issues/get_user_issues.dart';
import '../../../domain/usecases/issues/get_nearby_issues.dart';
import '../../../domain/usecases/issues/watch_public_issues.dart';
import '../../../data/repositories/issue_repository_impl.dart';

part 'issues_event.dart';
part 'issues_state.dart';

class IssuesBloc extends Bloc<IssuesEvent, IssuesState> {
  IssuesBloc({
    required CreateIssue createIssue,
    required GetUserIssues getUserIssues,
    required GetNearbyIssues getNearbyIssues,
    required WatchPublicIssues watchPublicIssues,
    required IssueRepositoryImpl issueRepository,
  })  : _createIssue = createIssue,
        _getUserIssues = getUserIssues,
        _getNearbyIssues = getNearbyIssues,
        _watchPublicIssues = watchPublicIssues,
        _issueRepository = issueRepository,
        super(const IssuesInitial()) {
    on<IssuesEvent>((event, emit) {
      emit(const IssuesLoading());
    });
    on<IssueCreateRequested>(_onCreateRequested);
    on<UserIssuesRequested>(_onUserIssuesRequested);
    on<NearbyIssuesRequested>(_onNearbyIssuesRequested);
    on<PublicIssuesWatchRequested>(_onPublicIssuesWatchRequested);
    on<PublicIssuesUpdated>(_onPublicIssuesUpdated);
  }

  final CreateIssue _createIssue;
  final GetUserIssues _getUserIssues;
  final GetNearbyIssues _getNearbyIssues;
  final WatchPublicIssues _watchPublicIssues;
  final IssueRepositoryImpl _issueRepository;

  StreamSubscription<List<Issue>>? _publicIssuesSubscription;

  @override
  Future<void> close() {
    _publicIssuesSubscription?.cancel();
    return super.close();
  }

  Future<void> _onCreateRequested(
    IssueCreateRequested event,
    Emitter<IssuesState> emit,
  ) async {
    emit(const IssuesLoading());

    try {
      // First upload images if any
      List<String> imageUrls = [];
      if (event.images.isNotEmpty) {
        // Generate a temporary issue ID for image upload
        final tempIssueId = DateTime.now().millisecondsSinceEpoch.toString();
        
        final imageResult = await _issueRepository.uploadImages(
          issueId: tempIssueId,
          images: event.images,
        );
        
        imageResult.fold(
          (failure) => throw Exception(failure.message),
          (urls) => imageUrls = urls,
        );
      }

      // Create the issue with uploaded image URLs
      final issue = Issue(
        id: '', // Will be set by Firestore
        title: event.title,
        description: event.description,
        category: event.category,
        subcategory: event.subcategory,
        priority: event.priority,
        status: 'submitted',
        location: event.location,
        images: imageUrls,
        reporterId: event.reporterId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await _createIssue(CreateIssueParams(issue: issue));

      result.fold(
        (failure) => emit(IssuesFailure(failure.message)),
        (issueId) => emit(IssueCreateSuccess(issueId)),
      );
    } catch (e) {
      emit(IssuesFailure(e.toString()));
    }
  }

  Future<void> _onUserIssuesRequested(
    UserIssuesRequested event,
    Emitter<IssuesState> emit,
  ) async {
    emit(const IssuesLoading());

    final result = await _getUserIssues(
      GetUserIssuesParams(userId: event.userId),
    );

    result.fold(
      (failure) => emit(IssuesFailure(failure.message)),
      (issues) => emit(UserIssuesLoaded(issues)),
    );
  }

  Future<void> _onNearbyIssuesRequested(
    NearbyIssuesRequested event,
    Emitter<IssuesState> emit,
  ) async {
    emit(const IssuesLoading());

    final result = await _getNearbyIssues(
      GetNearbyIssuesParams(
        location: event.location,
        radiusInKm: event.radiusInKm,
      ),
    );

    result.fold(
      (failure) => emit(IssuesFailure(failure.message)),
      (issues) => emit(NearbyIssuesLoaded(issues)),
    );
  }

  Future<void> _onPublicIssuesWatchRequested(
    PublicIssuesWatchRequested event,
    Emitter<IssuesState> emit,
  ) async {
    emit(const IssuesLoading());

    try {
      _publicIssuesSubscription?.cancel();
      _publicIssuesSubscription = _watchPublicIssues().listen(
        (issues) => add(PublicIssuesUpdated(issues)),
      );
    } catch (e) {
      emit(IssuesFailure(e.toString()));
    }
  }

  void _onPublicIssuesUpdated(
    PublicIssuesUpdated event,
    Emitter<IssuesState> emit,
  ) {
    emit(PublicIssuesLoaded(event.issues));
  }
}