import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/injection_container.dart' as di;
import '../../../domain/entities/issue.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/issues/issues_bloc.dart';
import '../../widgets/issue_card.dart';
import 'issue_detail_page.dart';

class MyReportsPage extends StatelessWidget {
  const MyReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<IssuesBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Reports'),
          centerTitle: true,
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! AuthSuccess) {
              return const Center(
                child: Text('Please sign in to view your reports'),
              );
            }

            return BlocBuilder<IssuesBloc, IssuesState>(
              builder: (context, issuesState) {
                if (issuesState is IssuesInitial) {
                  // Load user issues when page opens
                  context.read<IssuesBloc>().add(
                        UserIssuesRequested(userId: authState.user.id),
                      );
                  return const Center(child: CircularProgressIndicator());
                }

                if (issuesState is IssuesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (issuesState is IssuesFailure) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load reports',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          issuesState.message,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            context.read<IssuesBloc>().add(
                                  UserIssuesRequested(userId: authState.user.id),
                                );
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (issuesState is UserIssuesLoaded) {
                  final issues = issuesState.issues;

                  if (issues.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.report_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Reports Yet',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start by reporting your first civic issue',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop(); // Go back to home
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Report Issue'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<IssuesBloc>().add(
                            UserIssuesRequested(userId: authState.user.id),
                          );
                    },
                    child: Column(
                      children: [
                        // Summary Cards
                        _buildSummaryCards(context, issues),
                        
                        // Issues List
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: issues.length,
                            itemBuilder: (context, index) {
                              final issue = issues[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: IssueCard(
                                  issue: issue,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => IssueDetailPage(
                                          issueId: issue.id,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return const Center(child: CircularProgressIndicator());
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, List<Issue> issues) {
    final submitted = issues.where((i) => i.isSubmitted).length;
    final inProgress = issues.where((i) => i.isInProgress).length;
    final resolved = issues.where((i) => i.isResolved).length;
    final total = issues.length;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              context,
              'Total',
              total.toString(),
              Icons.list_alt,
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              context,
              'Pending',
              submitted.toString(),
              Icons.pending,
              Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              context,
              'In Progress',
              inProgress.toString(),
              Icons.work,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              context,
              'Resolved',
              resolved.toString(),
              Icons.check_circle,
              Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}