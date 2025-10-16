import 'package:flutter/material.dart';
import '../../models/alert_model.dart';
import '../../services/alert_service.dart';
import '../../widgets/alert_widget.dart';
import 'alert_detail_page.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  List<CommunityAlert> _alerts = [];
  List<CommunityAlert> _filteredAlerts = [];
  bool _isLoading = true;
  AlertType? _selectedFilter;
  bool _showOnlyUnread = false;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final alerts = await AlertService.loadAlerts();
      setState(() {
        _alerts = alerts;
        _filteredAlerts = alerts;
      });
      _applyFilters();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading alerts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredAlerts = _alerts.where((alert) {
        // Filter by type
        if (_selectedFilter != null && alert.type != _selectedFilter) {
          return false;
        }
        
        // Filter by read status
        if (_showOnlyUnread && alert.isRead) {
          return false;
        }
        
        // Filter out expired alerts
        if (alert.isExpired) {
          return false;
        }
        
        return true;
      }).toList();

      // Sort by priority and timestamp
      _filteredAlerts.sort((a, b) {
        // Critical alerts first
        if (a.isCritical && !b.isCritical) return -1;
        if (!a.isCritical && b.isCritical) return 1;
        
        // Then by timestamp (newest first)
        return b.timestamp.compareTo(a.timestamp);
      });
    });
  }

  Future<void> _markAsRead(CommunityAlert alert) async {
    if (alert.isRead) return;

    final success = await AlertService.markAlertAsRead(alert.id);
    if (success) {
      setState(() {
        final index = _alerts.indexWhere((a) => a.id == alert.id);
        if (index != -1) {
          _alerts[index] = alert.copyWith(isRead: true);
        }
      });
      _applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Alerts'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAlerts,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Section
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.grey[50],
              child: Column(
                children: [
                  // Type Filter
                  Row(
                    children: [
                      const Text('Filter by type: '),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<AlertType?>(
                          value: _selectedFilter,
                          isExpanded: true,
                          hint: const Text('All types'),
                          items: [
                            const DropdownMenuItem<AlertType?>(
                              value: null,
                              child: Text('All types'),
                            ),
                            ...AlertType.values.map((type) {
                              return DropdownMenuItem<AlertType?>(
                                value: type,
                                child: Text(_getTypeDisplayName(type)),
                              );
                            }),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedFilter = value;
                            });
                            _applyFilters();
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Unread Filter
                  Row(
                    children: [
                      Checkbox(
                        value: _showOnlyUnread,
                        onChanged: (value) {
                          setState(() {
                            _showOnlyUnread = value ?? false;
                          });
                          _applyFilters();
                        },
                      ),
                      const Text('Show only unread alerts'),
                    ],
                  ),
                ],
              ),
            ),

            // Alerts List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredAlerts.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          itemCount: _filteredAlerts.length,
                          itemBuilder: (context, index) {
                            final alert = _filteredAlerts[index];
                            return AlertWidget(
                              alert: alert,
                              onTap: () async {
                                await _markAsRead(alert);
                                if (mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AlertDetailPage(alert: alert.copyWith(isRead: true)),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _showOnlyUnread 
                ? 'No unread alerts'
                : _selectedFilter != null
                    ? 'No alerts for ${_getTypeDisplayName(_selectedFilter!)}'
                    : 'No alerts available',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for community updates',
            style: TextStyle(
              color: Colors.grey[500],
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
}