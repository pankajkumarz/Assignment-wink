import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/injection_container.dart' as di;
import '../../../domain/entities/issue.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/issues/issues_bloc.dart';
import '../../widgets/issue_card.dart';

class IssueManagementPage extends StatefulWidget {
  const IssueManagementPage({super.key});

  @override
  State<IssueManagementPage> createState() => _IssueManagementPageState();
}

class _IssueManagementPageState extends State<IssueManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<IssuesBloc>()
        ..add(PublicIssuesWatchRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Issue Management'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _showFilterDialog,
              icon: const Icon(Icons.filter_list),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'bulk_assign':
                    _showBulkAssignDialog();
                    break;
                  case 'bulk_status':
                    _showBulkStatusDialog();
                    break;
                  case 'export':
                    _exportData();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'bulk_assign',
                  child: Row(
                    children: [
                      Icon(Icons.assignment_ind),
                      SizedBox(width: 8),
                      Text('Bulk Assign'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'bulk_status',
                  child: Row(
                    children: [
                      Icon(Icons.update),
                      SizedBox(width: 8),
                      Text('Bulk Status Update'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      Icon(Icons.download),
                      SizedBox(width: 8),
                      Text('Export Data'),
                    ],
                  ),
                ),
              ],
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Pending'),
              Tab(text: 'In Progress'),
              Tab(text: 'Resolved'),
            ],
          ),
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is! AuthSuccess) {
              return const Center(
                child: Text('Please sign in to manage issues'),
              );
            }

            if (!authState.user.isAuthority && !authState.user.isAdmin) {
              return const Center(
                child: Text('Access denied. Authority privileges required.'),
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
                          'Failed to load issues',
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
                                  PublicIssuesWatchRequested(),
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
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      _buildIssuesList(context, issues),
                      _buildIssuesList(
                        context,
                        issues.where((i) => i.isSubmitted).toList(),
                      ),
                      _buildIssuesList(
                        context,
                        issues.where((i) => i.isInProgress).toList(),
                      ),
                      _buildIssuesList(
                        context,
                        issues.where((i) => i.isResolved).toList(),
                      ),
                    ],
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

  Widget _buildIssuesList(BuildContext context, List<Issue> issues) {
    final filteredIssues = _getFilteredIssues(issues);

    if (filteredIssues.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No issues found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'Issues matching your criteria will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<IssuesBloc>().add(PublicIssuesWatchRequested());
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredIssues.length,
        itemBuilder: (context, index) {
          final issue = filteredIssues[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: IssueCard(
              issue: issue,
              onTap: () => _showIssueActions(context, issue),
              onStatusChanged: (newStatus) {
                context.read<IssuesBloc>().add(
                  IssueStatusUpdateRequested(
                    issueId: issue.id,
                    newStatus: newStatus,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  List<Issue> _getFilteredIssues(List<Issue> issues) {
    if (_selectedFilter == 'all') {
      return issues;
    }

    return issues.where((issue) {
      switch (_selectedFilter) {
        case 'high_priority':
          return issue.priority == 'high' || issue.priority == 'emergency';
        case 'daily_life':
        case 'emergency':
        case 'general':
          return issue.category == _selectedFilter;
        default:
          return true;
      }
    }).toList();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Issues'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            'all',
            'high_priority',
            'daily_life',
            'emergency',
            'general',
          ].map((filter) {
            return RadioListTile<String>(
              title: Text(_getFilterDisplayName(filter)),
              value: filter,
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getFilterDisplayName(String filter) {
    switch (filter) {
      case 'all':
        return 'All Issues';
      case 'high_priority':
        return 'High Priority';
      case 'daily_life':
        return 'Daily Life';
      case 'emergency':
        return 'Emergency';
      case 'general':
        return 'General';
      default:
        return filter;
    }
  }

  void _showIssueActions(BuildContext context, Issue issue) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Issue Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Details'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Navigate to issue detail
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment_ind),
              title: const Text('Assign to Department'),
              onTap: () {
                Navigator.of(context).pop();
                _showAssignDialog(issue);
              },
            ),
            ListTile(
              leading: const Icon(Icons.update),
              title: const Text('Update Status'),
              onTap: () {
                Navigator.of(context).pop();
                _showStatusUpdateDialog(issue);
              },
            ),
            ListTile(
              leading: const Icon(Icons.comment),
              title: const Text('Add Comment'),
              onTap: () {
                Navigator.of(context).pop();
                _showCommentDialog(issue);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAssignDialog(Issue issue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Issue'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Assign this issue to a department:'),
            // TODO: Add department selection
            Text('Department assignment feature coming soon'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Assignment feature coming soon'),
                ),
              );
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  void _showStatusUpdateDialog(Issue issue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Update the status of this issue:'),
            // TODO: Add status selection
            Text('Status update feature coming soon'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Status update feature coming soon'),
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showCommentDialog(Issue issue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Comment'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add a comment to this issue:'),
            // TODO: Add comment input
            Text('Comment feature coming soon'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Comment feature coming soon'),
                ),
              );
            },
            child: const Text('Add Comment'),
          ),
        ],
      ),
    );
  }

  void _showBulkAssignDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bulk assignment feature coming soon'),
      ),
    );
  }

  void _showBulkStatusDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bulk status update feature coming soon'),
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data export feature coming soon'),
      ),
    );
  }
}