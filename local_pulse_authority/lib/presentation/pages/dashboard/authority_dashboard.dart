import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/services/injection_container.dart' as di;
import '../../../domain/entities/issue.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/issues/issues_bloc.dart';
import '../../widgets/issue_card.dart';
import '../issues/issue_management_page.dart';

class AuthorityDashboard extends StatelessWidget {
  const AuthorityDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<IssuesBloc>()
        ..add(const PublicIssuesWatchRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Authority Dashboard'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const IssueManagementPage(),
                  ),
                );
              },
              icon: const Icon(Icons.manage_accounts),
            ),
          ],
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! AuthSuccess) {
              return const Center(
                child: Text('Please sign in to access the dashboard'),
              );
            }

            if (!authState.user.isAuthority && !authState.user.isAdmin) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.security,
                      size: 64,
                      color: Colors.red,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Access Denied',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'You need authority privileges to access this dashboard',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return BlocBuilder<IssuesBloc, IssuesState>(
              builder: (context, issuesState) {
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
                          'Failed to load dashboard data',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          issuesState.message,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            context.read<IssuesBloc>().add(
                                  const PublicIssuesWatchRequested(),
                                );
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (issuesState is PublicIssuesLoaded) {
                  final issues = issuesState.issues;
                  return _buildDashboardContent(context, issues);
                }

                return const Center(child: CircularProgressIndicator());
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildDashboardContent(BuildContext context, List<Issue> issues) {
    final submitted = issues.where((i) => i.isSubmitted).length;
    final inProgress = issues.where((i) => i.isInProgress).length;
    final resolved = issues.where((i) => i.isResolved).length;
    final total = issues.length;

    final recentIssues = issues.take(5).toList();

    return RefreshIndicator(
      onRefresh: () async {
        context.read<IssuesBloc>().add(const PublicIssuesWatchRequested());
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Authority Dashboard',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Manage civic issues efficiently',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Statistics Cards
            Text(
              'Overview',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Total Issues',
                    total.toString(),
                    Icons.list_alt,
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Pending',
                    submitted.toString(),
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'In Progress',
                    inProgress.toString(),
                    Icons.work,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Resolved',
                    resolved.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Charts Section
            Text(
              'Analytics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Issue Status Distribution',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: submitted.toDouble(),
                              title: 'Pending\n$submitted',
                              color: Colors.orange,
                              radius: 60,
                            ),
                            PieChartSectionData(
                              value: inProgress.toDouble(),
                              title: 'In Progress\n$inProgress',
                              color: Colors.blue,
                              radius: 60,
                            ),
                            PieChartSectionData(
                              value: resolved.toDouble(),
                              title: 'Resolved\n$resolved',
                              color: Colors.green,
                              radius: 60,
                            ),
                          ],
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Recent Issues
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Issues',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const IssueManagementPage(),
                      ),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentIssues.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No issues reported yet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Issues will appear here when citizens report them',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...recentIssues.map((issue) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: IssueCard(
                      issue: issue,
                      onTap: () {
                        // TODO: Navigate to issue detail
                      },
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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