import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/services/injection_container.dart' as di;
import '../../../core/services/whatsapp_service.dart';
import '../../../domain/entities/issue.dart';
import '../../bloc/issues/issues_bloc.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/feedback_dialog.dart';

class IssueDetailPage extends StatelessWidget {
  const IssueDetailPage({
    super.key,
    required this.issueId,
  });

  final String issueId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<IssuesBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Issue Details'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () => _shareIssueViaWhatsApp(context),
              icon: const Icon(Icons.share),
            ),
          ],
        ),
        body: BlocBuilder<IssuesBloc, IssuesState>(
          builder: (context, state) {
            // For now, we'll show a placeholder since we don't have individual issue loading
            // In a real implementation, you'd load the specific issue by ID
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.construction,
                    size: 64,
                    color: Colors.orange,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Issue Detail View',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Coming soon...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIssueDetail(BuildContext context, Issue issue) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status and Priority Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(issue.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getStatusColor(issue.status),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getStatusDisplayName(issue.status),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _getStatusColor(issue.status),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getPriorityColor(issue.priority).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getPriorityIcon(issue.priority),
                      color: _getPriorityColor(issue.priority),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      issue.priority.toUpperCase(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getPriorityColor(issue.priority),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            issue.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            issue.description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          // Details Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    'Category',
                    '${_getCategoryDisplayName(issue.category)} • ${issue.subcategory}',
                    Icons.category,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    'Location',
                    issue.location.address,
                    Icons.location_on,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    'Reported',
                    _formatDateTime(issue.createdAt),
                    Icons.access_time,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    'Issue ID',
                    issue.id,
                    Icons.tag,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Images
          if (issue.images.isNotEmpty) ...[
            Text(
              'Photos',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: issue.images.length,
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: issue.images[index],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: const Icon(Icons.error),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],

          // Action Buttons
          if (issue.isResolved && issue.feedback == null) ...[
            CustomButton(
              onPressed: () {
                showFeedbackDialog(
                  context,
                  issue,
                  (rating, comment) {
                    // TODO: Submit feedback through BLoC
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Thank you for your feedback! Rating: $rating stars'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                );
              },
              text: 'Provide Feedback',
              icon: Icons.star,
            ),
            const SizedBox(height: 16),
          ],

          // Show existing feedback if available
          if (issue.feedback != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Your Feedback',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const Spacer(),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < issue.feedback!.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: index < issue.feedback!.rating
                                  ? Colors.amber
                                  : Colors.grey,
                              size: 20,
                            );
                          }),
                        ),
                      ],
                    ),
                    if (issue.feedback!.comment != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        issue.feedback!.comment!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      'Submitted on ${_formatDateTime(issue.feedback!.submittedAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'submitted':
        return Colors.orange;
      case 'acknowledged':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'submitted':
        return 'Submitted';
      case 'acknowledged':
        return 'Acknowledged';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      case 'rejected':
        return 'Rejected';
      default:
        return status.toUpperCase();
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'emergency':
        return Colors.red.shade800;
      default:
        return Colors.grey;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority) {
      case 'low':
        return Icons.keyboard_arrow_down;
      case 'medium':
        return Icons.remove;
      case 'high':
        return Icons.keyboard_arrow_up;
      case 'emergency':
        return Icons.warning;
      default:
        return Icons.remove;
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category) {
      case 'daily_life':
        return 'Daily Life';
      case 'emergency':
        return 'Emergency';
      case 'general':
        return 'General';
      default:
        return category;
    }
  }

  String _formatDateTime(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _shareIssueViaWhatsApp(BuildContext context) async {
    try {
      // For demo purposes, create a sample issue
      // In real implementation, you'd get the actual issue data
      final success = await WhatsAppService.instance.shareIssueReport(
        issueId: issueId,
        title: 'Sample Issue Report',
        description: 'This is a sample issue description for demonstration.',
        status: 'submitted',
        trackingUrl: 'https://localpulse.app/track/$issueId',
      );

      if (success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Issue shared successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to share issue. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing issue: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareViaWhatsApp(BuildContext context, Issue issue) async {
    try {
      final success = await WhatsAppService.instance.shareIssueReport(
        issueId: issue.id,
        title: issue.title,
        description: issue.description,
        status: issue.status,
        trackingUrl: 'https://localpulse.app/track/${issue.id}',
      );

      if (success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Issue shared via WhatsApp!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to share via WhatsApp. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing via WhatsApp: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}