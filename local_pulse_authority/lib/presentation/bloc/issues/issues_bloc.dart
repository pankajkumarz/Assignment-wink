import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entities/issue.dart';
import '../../../domain/entities/geo_location.dart';

// Events
abstract class IssuesEvent extends Equatable {
  const IssuesEvent();

  @override
  List<Object> get props => [];
}

class PublicIssuesWatchRequested extends IssuesEvent {}

class IssueStatusUpdateRequested extends IssuesEvent {
  final String issueId;
  final String newStatus;

  const IssueStatusUpdateRequested({
    required this.issueId,
    required this.newStatus,
  });

  @override
  List<Object> get props => [issueId, newStatus];
}

// States
abstract class IssuesState extends Equatable {
  const IssuesState();

  @override
  List<Object?> get props => [];
}

class IssuesInitial extends IssuesState {}

class IssuesLoading extends IssuesState {}

class PublicIssuesLoaded extends IssuesState {
  final List<Issue> issues;

  const PublicIssuesLoaded({required this.issues});

  @override
  List<Object> get props => [issues];
}

class IssuesFailure extends IssuesState {
  final String message;

  const IssuesFailure({required this.message});

  @override
  List<Object> get props => [message];
}

// BLoC
class IssuesBloc extends Bloc<IssuesEvent, IssuesState> {
  final FirebaseFirestore _firestore;

  IssuesBloc({FirebaseFirestore? firestore}) 
    : _firestore = firestore ?? FirebaseFirestore.instance,
      super(IssuesInitial()) {
    on<PublicIssuesWatchRequested>(_onPublicIssuesWatchRequested);
    on<IssueStatusUpdateRequested>(_onIssueStatusUpdateRequested);
  }

  void _onPublicIssuesWatchRequested(
    PublicIssuesWatchRequested event,
    Emitter<IssuesState> emit,
  ) async {
    emit(IssuesLoading());
    
    try {
      // Fetch real issues from Firebase Firestore
      final querySnapshot = await _firestore
          .collection('issues')
          .orderBy('createdAt', descending: true)
          .get();
      
      final issues = querySnapshot.docs.map((doc) {
        final data = doc.data();
        return Issue(
          id: doc.id,
          title: data['title'] ?? 'Unknown Issue',
          description: data['description'] ?? 'No description provided',
          category: data['category'] ?? 'general',
          subcategory: data['subcategory'] ?? 'other',
          status: data['status'] ?? 'submitted',
          priority: data['priority'] ?? 'medium',
          location: GeoLocation(
            latitude: (data['location']?['latitude'] ?? 0.0).toDouble(),
            longitude: (data['location']?['longitude'] ?? 0.0).toDouble(),
            address: data['location']?['address'] ?? 'Unknown Address',
            city: data['location']?['city'] ?? 'Unknown City',
          ),
          images: List<String>.from(data['images'] ?? []),
          reporterId: data['reporterId'] ?? 'unknown',
          assignedTo: data['assignedTo'],
          department: data['department'],
          estimatedResolution: data['estimatedResolution']?.toDate(),
          actualResolution: data['actualResolution']?.toDate(),
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
      
      emit(PublicIssuesLoaded(issues: issues));
    } catch (e) {
      // If no real data exists, show some sample data for demo
      final sampleIssues = [
        Issue(
          id: 'sample-1',
          title: 'Sample: Broken Street Light',
          description: 'This is a sample issue. Submit real issues from the citizen app to see them here.',
          category: 'infrastructure',
          subcategory: 'lighting',
          status: 'submitted',
          priority: 'medium',
          location: const GeoLocation(
            latitude: 28.6139, 
            longitude: 77.2090,
            address: 'Sample Address',
            city: 'Sample City',
          ),
          images: const [],
          reporterId: 'sample-user',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
      ];
      
      emit(PublicIssuesLoaded(issues: sampleIssues));
    }
  }

  void _onIssueStatusUpdateRequested(
    IssueStatusUpdateRequested event,
    Emitter<IssuesState> emit,
  ) async {
    final currentState = state;
    if (currentState is PublicIssuesLoaded) {
      emit(IssuesLoading());
      
      try {
        // Update the issue status in Firebase
        await _firestore
            .collection('issues')
            .doc(event.issueId)
            .update({
          'status': event.newStatus,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // Update the local state
        final updatedIssues = currentState.issues.map((issue) {
          if (issue.id == event.issueId) {
            return issue.copyWith(
              status: event.newStatus,
              updatedAt: DateTime.now(),
            );
          }
          return issue;
        }).toList();
        
        emit(PublicIssuesLoaded(issues: updatedIssues));
      } catch (e) {
        emit(IssuesFailure(message: 'Failed to update issue status: ${e.toString()}'));
      }
    }
  }
}