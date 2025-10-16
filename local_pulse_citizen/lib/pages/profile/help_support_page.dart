import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // Quick Help
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Help',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildHelpItem(
                    icon: Icons.help_outline,
                    title: 'How to Report an Issue',
                    subtitle: 'Learn how to report civic issues effectively',
                    onTap: () => _showHelpDialog(
                      context,
                      'How to Report an Issue',
                      'To report an issue:\n\n1. Tap the + button on the home screen\n2. Fill in the issue details\n3. Add photos if possible\n4. Select the appropriate category\n5. Set the priority level\n6. Submit your report\n\nYour location will be automatically captured to help authorities locate the issue.',
                    ),
                  ),
                  _buildHelpItem(
                    icon: Icons.track_changes,
                    title: 'Track Your Issues',
                    subtitle: 'Monitor the status of your reported issues',
                    onTap: () => _showHelpDialog(
                      context,
                      'Track Your Issues',
                      'You can track your issues by:\n\n1. Going to the "My Issues" tab\n2. View all your reported issues\n3. Check status updates\n4. See priority levels\n\nIssue statuses:\n• Submitted - Issue received\n• Acknowledged - Under review\n• In Progress - Being worked on\n• Resolved - Issue fixed\n• Closed - Issue completed',
                    ),
                  ),
                  _buildHelpItem(
                    icon: Icons.map,
                    title: 'Using the Map',
                    subtitle: 'Navigate and filter issues on the map',
                    onTap: () => _showHelpDialog(
                      context,
                      'Using the Map',
                      'The map feature allows you to:\n\n1. View all issues in your area\n2. Filter by category (Roads, Water, etc.)\n3. See issue details by tapping markers\n4. Check priority levels by color\n\nMap Colors:\n• Red - Critical priority\n• Orange - High priority\n• Yellow - Medium priority\n• Green - Low priority',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Contact Support
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Support',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildContactItem(
                    icon: Icons.email,
                    title: 'Email Support',
                    subtitle: 'support@localpulse.com',
                    onTap: () => _showContactDialog(
                      context,
                      'Email Support',
                      'Send us an email at support@localpulse.com\n\nWe typically respond within 24 hours.',
                    ),
                  ),
                  _buildContactItem(
                    icon: Icons.phone,
                    title: 'Phone Support',
                    subtitle: '+1 (555) 123-4567',
                    onTap: () => _showContactDialog(
                      context,
                      'Phone Support',
                      'Call us at +1 (555) 123-4567\n\nSupport Hours:\nMonday - Friday: 9 AM - 6 PM\nSaturday: 10 AM - 4 PM\nSunday: Closed',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // FAQ
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFAQItem(
                    'How long does it take to resolve issues?',
                    'Resolution time varies by issue type and priority. Critical issues are typically addressed within 24-48 hours, while routine maintenance may take 1-2 weeks.',
                  ),
                  _buildFAQItem(
                    'Can I report issues anonymously?',
                    'No, you need to be logged in to report issues. This helps authorities contact you for additional information if needed.',
                  ),
                  _buildFAQItem(
                    'What types of issues can I report?',
                    'You can report various civic issues including road problems, water issues, electrical problems, waste management, safety concerns, and other community issues.',
                  ),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1565C0).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF1565C0)),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.green),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            answer,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  void _showHelpDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(content),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it!'),
            ),
          ],
        );
      },
    );
  }

  void _showContactDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}