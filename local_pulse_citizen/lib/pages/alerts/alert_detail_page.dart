import 'package:flutter/material.dart';
import '../../models/alert_model.dart';
import '../../widgets/alert_widget.dart';

class AlertDetailPage extends StatelessWidget {
  final CommunityAlert alert;

  const AlertDetailPage({
    super.key,
    required this.alert,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert Details'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Alert Widget (full description)
              AlertWidget(
                alert: alert,
                showFullDescription: true,
              ),
              const SizedBox(height: 24),

              // Additional Details Section
              if (alert.imageUrl != null) ...[
                const Text(
                  'Image',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    alert.imageUrl!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Alert Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Alert Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildInfoRow('Type', _getTypeDisplayName(alert.type)),
                      _buildInfoRow('Priority', _getPriorityText(alert.priority)),
                      _buildInfoRow('Posted', _formatFullTimestamp(alert.timestamp)),
                      
                      if (alert.location != null)
                        _buildInfoRow('Location', alert.location!),
                      
                      if (alert.expiresAt != null)
                        _buildInfoRow(
                          'Expires',
                          alert.isExpired 
                              ? 'Expired'
                              : _formatFullTimestamp(alert.expiresAt!),
                        ),
                      
                      _buildInfoRow('Status', alert.isRead ? 'Read' : 'Unread'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Actions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // Share alert functionality
                            _shareAlert(context);
                          },
                          icon: const Icon(Icons.share),
                          label: const Text('Share Alert'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Report issue related to alert
                            _reportRelatedIssue(context);
                          },
                          icon: const Icon(Icons.report_problem),
                          label: const Text('Report Related Issue'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeDisplayName(AlertType type) {
    switch (type) {
      case AlertType.emergency:
        return 'Emergency';
      case AlertType.maintenance:
        return 'Maintenance';
      case AlertType.weather:
        return 'Weather';
      case AlertType.traffic:
        return 'Traffic';
      case AlertType.community:
        return 'Community';
      case AlertType.safety:
        return 'Safety';
      case AlertType.water:
        return 'Water';
      case AlertType.electricity:
        return 'Electricity';
      case AlertType.other:
        return 'Other';
    }
  }

  String _getPriorityText(AlertPriority priority) {
    switch (priority) {
      case AlertPriority.critical:
        return 'Critical';
      case AlertPriority.high:
        return 'High';
      case AlertPriority.medium:
        return 'Medium';
      case AlertPriority.low:
        return 'Low';
    }
  }

  String _formatFullTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} at ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  void _shareAlert(BuildContext context) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality would be implemented here'),
      ),
    );
  }

  void _reportRelatedIssue(BuildContext context) {
    // Navigate to report issue page with pre-filled information
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Would navigate to report issue page'),
      ),
    );
  }
}