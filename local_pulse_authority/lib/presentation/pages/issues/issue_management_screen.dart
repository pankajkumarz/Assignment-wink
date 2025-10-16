import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/issues/issues_bloc.dart';
import '../../widgets/issue_card.dart';

class IssueManagementScreen extends StatefulWidget {
  const IssueManagementScreen({super.key});

  @override
  State<IssueManagementScreen> createState() => _IssueManagementScreenState();
}

class _IssueManagementScreenState extends State<IssueManagementScreen> {
  String _selectedFilter = 'All';
  String _selectedPriority = 'All';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => IssuesBloc()..add(PublicIssuesWatchRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Issue Management'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _showFilterDialog,
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _showSearchDialog,
            ),
          ],
        ),
        body: Column(
          children: [
            // Filter Chips
            Container(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All', _selectedFilter),
                    const SizedBox(width: 8),
                    _buildFilterChip('Pending', _selectedFilter),
                    const SizedBox(width: 8),
                    _buildFilterChip('In Progress', _selectedFilter),
                    const SizedBox(width: 8),
                    _buildFilterChip('Resolved', _selectedFilter),
                    const SizedBox(width: 8),
                    _buildFilterChip('Emergency', _selectedFilter),
                  ],
                ),
              ),
            ),
            
            // Issues List
            Expanded(
              child: BlocBuilder<IssuesBloc, IssuesState>(
                builder: (context, state) {
                  if (state is IssuesLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  
                  if (state is IssuesFailure) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load issues',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
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
                  
                  if (state is PublicIssuesLoaded) {
                    final filteredIssues = _filterIssues(state.issues);
                    
                    if (filteredIssues.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No issues found',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters',
                              style: Theme.of(context).textTheme.bodyMedium,
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
                  
                  return const Center(
                    child: Text('No issues available'),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showCreateIssueDialog,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String selectedFilter) {
    final isSelected = selectedFilter == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? label : 'All';
        });
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  List<dynamic> _filterIssues(List<dynamic> issues) {
    var filtered = issues;
    
    if (_selectedFilter != 'All') {
      filtered = filtered.where((issue) {
        switch (_selectedFilter) {
          case 'Pending':
            return issue.status == 'submitted';
          case 'In Progress':
            return issue.status == 'in_progress';
          case 'Resolved':
            return issue.status == 'resolved';
          case 'Emergency':
            return issue.priority == 'high' || issue.priority == 'emergency';
          default:
            return true;
        }
      }).toList();
    }
    
    return filtered;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Issues'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Status'),
              subtitle: Text(_selectedFilter),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () {
                // Show status filter options
              },
            ),
            ListTile(
              title: const Text('Priority'),
              subtitle: Text(_selectedPriority),
              trailing: const Icon(Icons.arrow_drop_down),
              onTap: () {
                // Show priority filter options
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedFilter = 'All';
                _selectedPriority = 'All';
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Issues'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'Enter keywords...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showIssueActions(BuildContext context, dynamic issue) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              issue.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to issue details
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Update Status'),
              onTap: () {
                Navigator.pop(context);
                _showStatusUpdateDialog(context, issue);
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Add Comment'),
              onTap: () {
                Navigator.pop(context);
                // Show comment dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Assign to Team'),
              onTap: () {
                Navigator.pop(context);
                // Show assignment dialog
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusUpdateDialog(BuildContext context, dynamic issue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Issue Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Acknowledge'),
              leading: Radio<String>(
                value: 'acknowledged',
                groupValue: issue.status,
                onChanged: (value) {
                  if (value != null) {
                    context.read<IssuesBloc>().add(
                      IssueStatusUpdateRequested(
                        issueId: issue.id,
                        newStatus: value,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('In Progress'),
              leading: Radio<String>(
                value: 'in_progress',
                groupValue: issue.status,
                onChanged: (value) {
                  if (value != null) {
                    context.read<IssuesBloc>().add(
                      IssueStatusUpdateRequested(
                        issueId: issue.id,
                        newStatus: value,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('Resolved'),
              leading: Radio<String>(
                value: 'resolved',
                groupValue: issue.status,
                onChanged: (value) {
                  if (value != null) {
                    context.read<IssuesBloc>().add(
                      IssueStatusUpdateRequested(
                        issueId: issue.id,
                        newStatus: value,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCreateIssueDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Issue'),
        content: const Text('This feature allows authorities to create issues on behalf of citizens.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to create issue screen
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}