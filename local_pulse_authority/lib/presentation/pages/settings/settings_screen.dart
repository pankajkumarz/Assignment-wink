import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _autoAssignIssues = false;
  bool _emergencyAlerts = true;
  String _selectedLanguage = 'English';
  String _selectedTheme = 'System';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Authority Officer',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'officer@localpulse.gov',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _editProfile(context),
                    child: const Text('Edit Profile'),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Notifications Section
          Text(
            'Notifications',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Push Notifications'),
                  subtitle: const Text('Receive notifications for new issues'),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Emergency Alerts'),
                  subtitle: const Text('Immediate alerts for emergency issues'),
                  value: _emergencyAlerts,
                  onChanged: (value) {
                    setState(() {
                      _emergencyAlerts = value;
                    });
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Notification Sound'),
                  subtitle: const Text('Default'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _selectNotificationSound(context),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Issue Management Section
          Text(
            'Issue Management',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Auto-assign Issues'),
                  subtitle: const Text('Automatically assign issues based on location'),
                  value: _autoAssignIssues,
                  onChanged: (value) {
                    setState(() {
                      _autoAssignIssues = value;
                    });
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Default Priority'),
                  subtitle: const Text('Medium'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _selectDefaultPriority(context),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Response Time Targets'),
                  subtitle: const Text('Configure target response times'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _configureResponseTimes(context),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // App Preferences Section
          Text(
            'App Preferences',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Language'),
                  subtitle: Text(_selectedLanguage),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _selectLanguage(context),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Theme'),
                  subtitle: Text(_selectedTheme),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _selectTheme(context),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Data Usage'),
                  subtitle: const Text('Manage offline data and sync'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _manageDataUsage(context),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Security Section
          Text(
            'Security',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('Change Password'),
                  subtitle: const Text('Update your account password'),
                  leading: const Icon(Icons.lock),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _changePassword(context),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Two-Factor Authentication'),
                  subtitle: const Text('Add extra security to your account'),
                  leading: const Icon(Icons.security),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _setup2FA(context),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Active Sessions'),
                  subtitle: const Text('Manage logged-in devices'),
                  leading: const Icon(Icons.devices),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _manageSessions(context),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // About Section
          Text(
            'About',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('App Version'),
                  subtitle: const Text('1.0.0 (Build 1)'),
                  leading: const Icon(Icons.info),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Help & Support'),
                  subtitle: const Text('Get help and contact support'),
                  leading: const Icon(Icons.help),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showHelp(context),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Privacy Policy'),
                  subtitle: const Text('Read our privacy policy'),
                  leading: const Icon(Icons.privacy_tip),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showPrivacyPolicy(context),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('Terms of Service'),
                  subtitle: const Text('Read our terms of service'),
                  leading: const Icon(Icons.description),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showTerms(context),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Sign Out Button
          Card(
            child: ListTile(
              title: const Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: const Icon(Icons.logout, color: Colors.red),
              onTap: () => _signOut(context),
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _editProfile(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Name'),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(labelText: 'Phone'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _selectNotificationSound(BuildContext context) {
    // Implement notification sound selection
  }

  void _selectDefaultPriority(BuildContext context) {
    // Implement default priority selection
  }

  void _configureResponseTimes(BuildContext context) {
    // Implement response time configuration
  }

  void _selectLanguage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Hindi'),
              value: 'Hindi',
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _selectTheme(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Light'),
              value: 'Light',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('Dark'),
              value: 'Dark',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                });
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('System'),
              value: 'System',
              groupValue: _selectedTheme,
              onChanged: (value) {
                setState(() {
                  _selectedTheme = value!;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _manageDataUsage(BuildContext context) {
    // Implement data usage management
  }

  void _changePassword(BuildContext context) {
    // Implement password change
  }

  void _setup2FA(BuildContext context) {
    // Implement 2FA setup
  }

  void _manageSessions(BuildContext context) {
    // Implement session management
  }

  void _showHelp(BuildContext context) {
    // Implement help screen
  }

  void _showPrivacyPolicy(BuildContext context) {
    // Implement privacy policy screen
  }

  void _showTerms(BuildContext context) {
    // Implement terms screen
  }

  void _signOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement sign out logic
              Navigator.of(context).pushReplacementNamed('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}