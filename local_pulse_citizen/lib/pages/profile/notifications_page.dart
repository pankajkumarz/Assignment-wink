import 'package:flutter/material.dart';
import '../../services/notification_preferences_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  NotificationSettings? _settings;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final settings = await NotificationPreferencesService.loadSettings();
      setState(() {
        _settings = settings;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading settings: $e'),
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

  Future<void> _toggleSetting(String key, bool value) async {
    if (_settings == null) return;

    setState(() {
      switch (key) {
        case 'pushNotifications':
          _settings = _settings!.copyWith(pushNotifications: value);
          break;
        case 'emailNotifications':
          _settings = _settings!.copyWith(emailNotifications: value);
          break;
        case 'issueUpdates':
          _settings = _settings!.copyWith(issueUpdates: value);
          break;
        case 'communityAlerts':
          _settings = _settings!.copyWith(communityAlerts: value);
          break;
        case 'maintenanceNotifications':
          _settings = _settings!.copyWith(maintenanceNotifications: value);
          break;
        case 'soundEnabled':
          _settings = _settings!.copyWith(soundEnabled: value);
          break;
        case 'vibrationEnabled':
          _settings = _settings!.copyWith(vibrationEnabled: value);
          break;
      }
    });

    // Save immediately when toggled
    final success = await NotificationPreferencesService.toggleSetting(key, value);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save setting'),
          backgroundColor: Colors.red,
        ),
      );
      // Revert the change
      await _loadSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          // General Notifications
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'General Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Push Notifications'),
                    subtitle: const Text('Receive notifications on your device'),
                    value: _settings?.pushNotifications ?? true,
                    onChanged: (value) => _toggleSetting('pushNotifications', value),
                  ),
                  SwitchListTile(
                    title: const Text('Email Notifications'),
                    subtitle: const Text('Receive notifications via email'),
                    value: _settings?.emailNotifications ?? true,
                    onChanged: (value) => _toggleSetting('emailNotifications', value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Issue Notifications
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Issue Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Issue Updates'),
                    subtitle: const Text('Get notified when your issues are updated'),
                    value: _settings?.issueUpdates ?? true,
                    onChanged: (value) => _toggleSetting('issueUpdates', value),
                  ),
                  SwitchListTile(
                    title: const Text('Community Alerts'),
                    subtitle: const Text('Receive alerts about issues in your area'),
                    value: _settings?.communityAlerts ?? true,
                    onChanged: (value) => _toggleSetting('communityAlerts', value),
                  ),
                  SwitchListTile(
                    title: const Text('Maintenance Notifications'),
                    subtitle: const Text('Get notified about scheduled maintenance'),
                    value: _settings?.maintenanceNotifications ?? false,
                    onChanged: (value) => _toggleSetting('maintenanceNotifications', value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sound & Vibration
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sound & Vibration',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Sound'),
                    subtitle: const Text('Play sound for notifications'),
                    value: _settings?.soundEnabled ?? true,
                    onChanged: (value) => _toggleSetting('soundEnabled', value),
                  ),
                  SwitchListTile(
                    title: const Text('Vibration'),
                    subtitle: const Text('Vibrate for notifications'),
                    value: _settings?.vibrationEnabled ?? true,
                    onChanged: (value) => _toggleSetting('vibrationEnabled', value),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

                // Save Button
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveAllSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1565C0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Saving...'),
                          ],
                        )
                      : const Text('Save All Settings'),
                ),
        ],
        ),
      ),
    );
  }

  Future<void> _saveAllSettings() async {
    if (_settings == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final success = await NotificationPreferencesService.saveSettings(_settings!);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification settings saved!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        throw Exception('Failed to save settings');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }
}