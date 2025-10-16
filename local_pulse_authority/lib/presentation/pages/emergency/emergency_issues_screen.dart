import 'package:flutter/material.dart';
import '../alerts/create_alert_screen.dart';

class EmergencyIssuesScreen extends StatelessWidget {
  const EmergencyIssuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Issues'),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh emergency issues
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Emergency Alert Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.red[50],
            child: Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Colors.red[700],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency Response Center',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                      Text(
                        'High priority issues requiring immediate attention',
                        style: TextStyle(
                          color: Colors.red[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Emergency Statistics
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildEmergencyStatCard(
                    context,
                    'Active Emergencies',
                    '3',
                    Icons.emergency,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildEmergencyStatCard(
                    context,
                    'Response Time',
                    '12 min',
                    Icons.timer,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          
          // Emergency Issues List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _getEmergencyIssues().length,
              itemBuilder: (context, index) {
                final issue = _getEmergencyIssues()[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border(
                        left: BorderSide(
                          width: 4,
                          color: _getPriorityColor(issue['priority']!),
                        ),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: _getPriorityColor(issue['priority']!),
                        child: Icon(
                          _getPriorityIcon(issue['priority']!),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        issue['title']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(issue['location']!),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(issue['priority']!),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  issue['priority']!.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                issue['time']!,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                      onTap: () => _showEmergencyActions(context, issue),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _sendEmergencyAlert(context),
        backgroundColor: Colors.red[700],
        child: const Icon(
          Icons.add_alert,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildEmergencyStatCard(
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
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _getEmergencyIssues() {
    return [
      {
        'title': 'Gas Leak Emergency',
        'location': 'Residential Complex, Block C',
        'priority': 'Critical',
        'time': '5 min ago',
        'status': 'Active',
      },
      {
        'title': 'Water Main Burst',
        'location': 'Main Street Junction',
        'priority': 'High',
        'time': '15 min ago',
        'status': 'Responding',
      },
      {
        'title': 'Power Outage',
        'location': 'Industrial Area, Sector 8',
        'priority': 'High',
        'time': '32 min ago',
        'status': 'In Progress',
      },
      {
        'title': 'Tree Fall Blocking Road',
        'location': 'Highway 1, KM 25',
        'priority': 'Medium',
        'time': '1 hour ago',
        'status': 'Assigned',
      },
    ];
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'critical':
        return Colors.red[800]!;
      case 'high':
        return Colors.red[600]!;
      case 'medium':
        return Colors.orange[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  IconData _getPriorityIcon(String priority) {
    switch (priority.toLowerCase()) {
      case 'critical':
        return Icons.dangerous;
      case 'high':
        return Icons.priority_high;
      case 'medium':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  void _showEmergencyActions(BuildContext context, Map<String, String> issue) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.emergency,
                    color: Colors.red[700],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          issue['title']!,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                        Text(
                          'Priority: ${issue['priority']}',
                          style: TextStyle(
                            color: Colors.red[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('Call Emergency Services'),
              onTap: () {
                Navigator.pop(context);
                _callEmergencyServices();
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.blue),
              title: const Text('Dispatch Response Team'),
              onTap: () {
                Navigator.pop(context);
                _dispatchTeam(context, issue);
              },
            ),
            ListTile(
              leading: const Icon(Icons.update, color: Colors.orange),
              title: const Text('Update Status'),
              onTap: () {
                Navigator.pop(context);
                _updateEmergencyStatus(context, issue);
              },
            ),
            ListTile(
              leading: const Icon(Icons.message, color: Colors.purple),
              title: const Text('Send Alert to Citizens'),
              onTap: () {
                Navigator.pop(context);
                _sendCitizenAlert(context, issue);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add_alert, color: Colors.red[700]),
            const SizedBox(width: 8),
            const Text('Create Emergency Alert'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Emergency Type',
                hintText: 'e.g., Gas Leak, Fire, Flood',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Location',
                hintText: 'Exact location of emergency',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Detailed description of the emergency',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _createEmergencyAlert(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Create Alert'),
          ),
        ],
      ),
    );
  }

  void _callEmergencyServices() {
    // Implement emergency services call
  }

  void _dispatchTeam(BuildContext context, Map<String, String> issue) {
    // Implement team dispatch
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Response team dispatched for ${issue['title']}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _updateEmergencyStatus(BuildContext context, Map<String, String> issue) {
    // Implement status update
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status updated for ${issue['title']}'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _sendCitizenAlert(BuildContext context, Map<String, String> issue) {
    // Implement citizen alert
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alert sent to citizens about ${issue['title']}'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _createEmergencyAlert(BuildContext context) {
    // Implement emergency alert creation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Emergency alert created successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _sendEmergencyAlert(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateAlertScreen(isEmergency: true),
      ),
    );
  }
}