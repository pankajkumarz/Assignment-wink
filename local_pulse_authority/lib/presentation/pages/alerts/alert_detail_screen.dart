import 'package:flutter/material.dart';
import '../../../domain/entities/alert.dart';
import '../../../services/alert_service.dart';

class AlertDetailScreen extends StatefulWidget {
  final Alert alert;

  const AlertDetailScreen({
    super.key,
    required this.alert,
  });

  @override
  State<AlertDetailScreen> createState() => _AlertDetailScreenState();
}

class _AlertDetailScreenState extends State<AlertDetailScreen> {
  late Alert _alert;

  @override
  void initState() {
    super.initState();
    _alert = widget.alert;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert Details'),
        backgroundColor: _alert.isEmergency ? Colors.red[700] : Theme.of(context).colorScheme.inversePrimary,
        foregroundColor: _alert.isEmergency ? Colors.white : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareAlert(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_status',
                child: Text(_alert.isActive ? 'Deactivate Alert' : 'Activate Alert'),
              ),
              const PopupMenuItem(
                value: 'duplicate',
                child: Text('Duplicate Alert'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete Alert'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            if (!_alert.isActive || _alert.isExpired) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _alert.isExpired ? Colors.orange[50] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _alert.isExpired ? Colors.orange[300]! : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _alert.isExpired ? Icons.schedule : Icons.visibility_off,
                      color: _alert.isExpired ? Colors.orange[700] : Colors.grey[700],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _alert.isExpired ? 'This alert has expired' : 'This alert is inactive',
                      style: TextStyle(
                        color: _alert.isExpired ? Colors.orange[700] : Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Priority and Type Badges
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(_alert.priority),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _alert.priorityDisplayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _alert.typeDisplayName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Title and Message
            Text(
              _alert.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              _alert.message,
              style: Theme.of(context).textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),

            // Location Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Location & Coverage',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('City', _alert.city),
                    _buildInfoRow('Address', _alert.location.address),
                    _buildInfoRow('Coordinates', '${_alert.location.latitude.toStringAsFixed(4)}, ${_alert.location.longitude.toStringAsFixed(4)}'),
                    _buildInfoRow('Coverage Radius', '${_alert.radiusKm} km'),
                    if (_alert.estimatedAffectedPeople != null)
                      _buildInfoRow('Estimated Affected People', '~${_alert.estimatedAffectedPeople}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Alert Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Alert Information',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Created By', _alert.createdBy),
                    _buildInfoRow('Created At', _formatDateTime(_alert.createdAt)),
                    if (_alert.expiresAt != null)
                      _buildInfoRow('Expires At', _formatDateTime(_alert.expiresAt!)),
                    if (_alert.category != null)
                      _buildInfoRow('Category', _alert.category!.toUpperCase()),
                    _buildInfoRow('Status', _alert.isActive ? 'Active' : 'Inactive'),
                  ],
                ),
              ),
            ),

            if (_alert.tags != null && _alert.tags!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tags',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: _alert.tags!.map((tag) {
                          return Chip(
                            label: Text(tag),
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (_alert.actionUrl != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Action Link',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _openActionUrl(),
                        child: Text(
                          _alert.actionUrl!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _toggleAlertStatus(),
                    icon: Icon(_alert.isActive ? Icons.visibility_off : Icons.visibility),
                    label: Text(_alert.isActive ? 'Deactivate' : 'Activate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _alert.isActive ? Colors.orange : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _duplicateAlert(),
                    icon: const Icon(Icons.copy),
                    label: const Text('Duplicate'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _deleteAlert(),
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text('Delete Alert', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'emergency':
      case 'critical':
        return Colors.red[700]!;
      case 'high':
        return Colors.red[500]!;
      case 'medium':
        return Colors.orange[600]!;
      case 'low':
        return Colors.green[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'toggle_status':
        _toggleAlertStatus();
        break;
      case 'duplicate':
        _duplicateAlert();
        break;
      case 'delete':
        _deleteAlert();
        break;
    }
  }

  Future<void> _toggleAlertStatus() async {
    try {
      await AlertService.updateAlertStatus(_alert.id, !_alert.isActive);
      
      setState(() {
        _alert = _alert.copyWith(isActive: !_alert.isActive);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _alert.isActive ? 'Alert activated' : 'Alert deactivated',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update alert: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _duplicateAlert() {
    // TODO: Navigate to create alert screen with pre-filled data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Duplicate feature coming soon'),
      ),
    );
  }

  Future<void> _deleteAlert() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alert'),
        content: const Text('Are you sure you want to delete this alert? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AlertService.deleteAlert(_alert.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alert deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete alert: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _shareAlert() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share feature coming soon'),
      ),
    );
  }

  void _openActionUrl() {
    // TODO: Implement URL launcher
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening: ${_alert.actionUrl}'),
      ),
    );
  }
}