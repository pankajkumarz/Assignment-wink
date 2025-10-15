part of 'issues_bloc.dart';

abstract class IssuesState extends Equatable {
  const IssuesState();

  @override
  List<Object?> get props => [];
}

class IssuesInitial extends IssuesState {
  const IssuesInitial();
}

class IssuesLoading extends IssuesState {
  const IssuesLoading();
}

class IssueCreateSuccess extends IssuesState {
  const IssueCreateSuccess(this.issueId);

  final String issueId;

  @override
  List<Object> get props => [issueId];
}

class UserIssuesLoaded extends IssuesState {
  const UserIssuesLoaded(this.issues);

  final List<Issue> issues;

  @override
  List<Object> get props => [issues];
}

class NearbyIssuesLoaded extends IssuesState {
  const NearbyIssuesLoaded(this.issues);

  final List<Issue> issues;

  @override
  List<Object> get props => [issues];
}

class PublicIssuesLoaded extends IssuesState {
  const PublicIssuesLoaded(this.issues);

  final List<Issue> issues;

  @override
  List<Object> get props => [issues];
}

class IssuesFailure extends IssuesState {
  const IssuesFailure(this.message);

  final String message;

  @override
  List<Object> get props => [message];
}