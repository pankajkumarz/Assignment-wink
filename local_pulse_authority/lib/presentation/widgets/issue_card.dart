import 'package:flutter/material.dart';
import '../../domain/entities/issue.dart';
import '../../core/constants/app_constants.dart';

class IssueCard extends StatelessWidget {
  final Issue issue;
  final VoidCallback? onTap;
  final Function(String)? onStatusChanged;

  const IssueCard({
    super.key,
    required this.issue,
    this.onTap,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      issue.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(context),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                issue.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${issue.location.latitude.toStringAsFixed(4)}, ${issue.location.longitude.toStringAsFixed(4)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  _buildPriorityIndicator(context),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Category: ${issue.category}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    _formatDate(issue.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              if (onStatusChanged != null) ...[
                const SizedBox(height: 12),
                _buildStatusActions(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color chipColor;
    String statusText;

    switch (issue.status) {
      case AppConstants.statusSubmitted:
        chipColor = Colors.blue;
        statusText = 'Submitted';
        break;
      case AppConstants.statusAcknowledged:
        chipColor = Colors.orange;
        statusText = 'Acknowledged';
        break;
      case AppConstants.statusInProgress:
        chipColor = Colors.purple;
        statusText = 'In Progress';
        break;
      case AppConstants.statusResolved:
        chipColor = Colors.green;
        statusText = 'Resolved';
        break;
      case AppConstants.statusClosed:
        chipColor = Colors.grey;
        statusText = 'Closed';
        break;
      case AppConstants.statusRejected:
        chipColor = Colors.red;
        statusText = 'Rejected';
        break;
      default:
        chipColor = Colors.grey;
        statusText = 'Unknown';
    }

    return Chip(
      label: Text(
        statusText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildPriorityIndicator(BuildContext context) {
    Color priorityColor;
    IconData priorityIcon;

    switch (issue.priority) {
      case 'high':
        priorityColor = Colors.red;
        priorityIcon = Icons.priority_high;
        break;
      case 'medium':
        priorityColor = Colors.orange;
        priorityIcon = Icons.remove;
        break;
      case 'low':
        priorityColor = Colors.green;
        priorityIcon = Icons.keyboard_arrow_down;
        break;
      default:
        priorityColor = Colors.grey;
        priorityIcon = Icons.help_outline;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          priorityIcon,
          size: 16,
          color: priorityColor,
        ),
        const SizedBox(width: 4),
        Text(
          issue.priority.toUpperCase(),
          style: TextStyle(
            color: priorityColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusActions(BuildContext context) {
    final availableStatuses = [
      AppConstants.statusAcknowledged,
      AppConstants.statusInProgress,
      AppConstants.statusResolved,
      AppConstants.statusRejected,
    ];

    return Wrap(
      spacing: 8,
      children: availableStatuses
          .where((status) => status != issue.status)
          .map((status) => ActionChip(
                label: Text(_getStatusDisplayName(status)),
                onPressed: () => onStatusChanged?.call(status),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ))
          .toList(),
    );
  }

  String _getStatusDisplayName(String status) {
    switch (status) {
      case AppConstants.statusAcknowledged:
        return 'Acknowledge';
      case AppConstants.statusInProgress:
        return 'Start Work';
      case AppConstants.statusResolved:
        return 'Mark Resolved';
      case AppConstants.statusRejected:
        return 'Reject';
      default:
        return status;
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