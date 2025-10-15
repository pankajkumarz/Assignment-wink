import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../domain/entities/issue.dart';

class IssueCard extends StatelessWidget {
  const IssueCard({
    super.key,
    required this.issue,
    required this.onTap,
  });

  final Issue issue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Status Chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(issue.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(issue.status),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getStatusDisplayName(issue.status),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: _getStatusColor(issue.status),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const Spacer(),
                  // Priority Indicator
                  Icon(
                    _getPriorityIcon(issue.priority),
                    color: _getPriorityColor(issue.priority),
                    size: 20,
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
              const SizedBox(height: 12),

              // Title
              Text(
                issue.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                issue.description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Category and Location
              Row(
                children: [
                  Icon(
                    Icons.category,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_getCategoryDisplayName(issue.category)} • ${issue.subcategory}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      issue.location.address,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Images Preview
              if (issue.images.isNotEmpty) ...[
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: issue.images.length > 3 ? 3 : issue.images.length,
                    itemBuilder: (context, index) {
                      if (index == 2 && issue.images.length > 3) {
                        // Show "+X more" indicator
                        return Container(
                          width: 60,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '+${issue.images.length - 2}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        );
                      }

                      return Container(
                        width: 60,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
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
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Footer
              Row(
                children: [
                  Text(
                    _formatDate(issue.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    'ID: ${issue.id.substring(0, 8)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontFamily: 'monospace',
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}