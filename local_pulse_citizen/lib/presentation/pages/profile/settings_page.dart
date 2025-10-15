import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/whatsapp_service.dart';
import '../../../domain/entities/user.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthSuccess) {
            return _buildSettingsContent(context, state.user);
          } else {
            return const Center(
              child: Text('Please sign in to access settings'),
            );
          }
        },
      ),
    );
  }

  Widget _buildSettingsContent(BuildContext context, User user) {
    return ListView(
      children: [
        // Theme Section
        _buildSectionHeader(context, 'Appearance'),
        _buildThemeSettings(context, user),
        const Divider(),

        // Language Section
        _buildSectionHeader(context, 'Language'),
        _buildLanguageSettings(context, user),
        const Divider(),

        // Notifications Section
        _buildSectionHeader(context, 'Notifications'),
        _buildNotificationSettings(context, user),
        const Divider(),

        // Privacy Section
        _buildSectionHeader(context, 'Privacy & Security'),
        _buildPrivacySettings(context),
        const Divider(),

        // About Section
        _buildSectionHeader(context, 'About'),
        _buildAboutSettings(context),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildThemeSettings(BuildContext context, User user) {
    return Column(
      children: [
        BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            return ListTile(
              leading: const Icon(Icons.palette_outlined),
              title: const Text('Theme'),
              subtitle: Text(_getThemeDisplayName(themeState.themeMode)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showThemeDialog(context, user),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLanguageSettings(BuildContext context, User user) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.language_outlined),
          title: const Text('Language'),
          subtitle: Text(_getLanguageDisplayName(user.preferences.language)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showLanguageDialog(context, user),
        ),
      ],
    );
  }

  Widget _buildNotificationSettings(BuildContext context, User user) {
    return Column(
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.notifications_outlined),
          title: const Text('Push Notifications'),
          subtitle: const Text('Receive notifications for issue updates'),
          value: user.preferences.notifications.pushEnabled,
          onChanged: (value) {
            // TODO: Update notification preferences
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Notification settings update coming soon'),
              ),
            );
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.email_outlined),
          title: const Text('Email Notifications'),
          subtitle: const Text('Receive email updates for your reports'),
          value: user.preferences.notifications.emailEnabled,
          onChanged: (value) {
            // TODO: Update notification preferences
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.message_outlined),
          title: const Text('WhatsApp Notifications'),
          subtitle: const Text('Receive updates via WhatsApp'),
          value: user.preferences.notifications.whatsappEnabled,
          onChanged: (value) {
            // TODO: Update notification preferences
          },
        ),
        SwitchListTile(
          secondary: const Icon(Icons.warning_outlined),
          title: const Text('Alert Notifications'),
          subtitle: const Text('Receive civic alerts for your area'),
          value: user.preferences.notifications.alerts,
          onChanged: (value) {
            // TODO: Update notification preferences
          },
        ),
      ],
    );
  }

  Widget _buildPrivacySettings(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.lock_outlined),
          title: const Text('Change Password'),
          subtitle: const Text('Update your account password'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Implement change password
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Change password feature coming soon'),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.download_outlined),
          title: const Text('Download My Data'),
          subtitle: const Text('Export your account data'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Implement data export
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data export feature coming soon'),
              ),
            );
          },
        ),
        ListTile(
          leading: Icon(
            Icons.delete_forever_outlined,
            color: Theme.of(context).colorScheme.error,
          ),
          title: Text(
            'Delete Account',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          subtitle: const Text('Permanently delete your account'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Implement account deletion
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account deletion feature coming soon'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAboutSettings(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.info_outlined),
          title: const Text('About Local Pulse'),
          subtitle: const Text('Version 1.0.0'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: 'Local Pulse',
              applicationVersion: '1.0.0',
              applicationIcon: const Icon(Icons.location_city, size: 48),
              children: [
                const Text(
                  'Local Pulse helps citizens report and track civic issues in their community, promoting transparency and accountability.',
                ),
              ],
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Privacy Policy'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Show privacy policy
          },
        ),
        ListTile(
          leading: const Icon(Icons.description_outlined),
          title: const Text('Terms of Service'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Show terms of service
          },
        ),
        ListTile(
          leading: const Icon(Icons.share_outlined),
          title: const Text('Share App'),
          subtitle: const Text('Invite friends to use Local Pulse'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _shareAppInvitation(context),
        ),
        ListTile(
          leading: const Icon(Icons.help_outlined),
          title: const Text('Help & Support'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: Show help page
          },
        ),
      ],
    );
  }

  String _getThemeDisplayName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  String _getLanguageDisplayName(String language) {
    switch (language) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिंदी (Hindi)';
      default:
        return 'English';
    }
  }

  void _showThemeDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return AlertDialog(
            title: const Text('Choose Theme'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('Light'),
                  value: ThemeMode.light,
                  groupValue: themeState.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<ThemeBloc>().add(ThemeChanged(value));
                    }
                    Navigator.of(context).pop();
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark'),
                  value: ThemeMode.dark,
                  groupValue: themeState.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<ThemeBloc>().add(ThemeChanged(value));
                    }
                    Navigator.of(context).pop();
                  },
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('System Default'),
                  value: ThemeMode.system,
                  groupValue: themeState.themeMode,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<ThemeBloc>().add(ThemeChanged(value));
                    }
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'en',
              groupValue: user.preferences.language,
              onChanged: (value) {
                Navigator.of(context).pop();
                // TODO: Update language preference
              },
            ),
            RadioListTile<String>(
              title: const Text('हिंदी (Hindi)'),
              value: 'hi',
              groupValue: user.preferences.language,
              onChanged: (value) {
                Navigator.of(context).pop();
                // TODO: Update language preference
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareAppInvitation(BuildContext context) async {
    try {
      final success = await WhatsAppService.instance.shareAppInvitation();
      
      if (success) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('App invitation shared successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to share app invitation. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing app invitation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}