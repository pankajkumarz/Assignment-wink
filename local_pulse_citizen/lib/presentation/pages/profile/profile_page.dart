import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/user.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../widgets/custom_button.dart';
import 'edit_profile_page.dart';
import 'settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthSuccess) {
            return _buildProfileContent(context, state.user);
          } else {
            return const Center(
              child: Text('Please sign in to view your profile'),
            );
          }
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Profile Picture
          CircleAvatar(
            radius: 60,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 24),

          // User Info
          Text(
            user.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),

          // Profile Details Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile Details',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    context,
                    'City',
                    user.city,
                    Icons.location_city,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    'Age',
                    '${user.age} years',
                    Icons.cake,
                  ),
                  if (user.phone != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      context,
                      'Phone',
                      user.phone!,
                      Icons.phone,
                    ),
                  ],
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    'Role',
                    user.role.toUpperCase(),
                    Icons.badge,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    'Member Since',
                    _formatDate(user.createdAt),
                    Icons.calendar_today,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons
          CustomButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EditProfilePage(user: user),
                ),
              );
            },
            text: 'Edit Profile',
            icon: Icons.edit,
          ),
          const SizedBox(height: 16),
          CustomButton(
            onPressed: () => _showSignOutDialog(context),
            text: 'Sign Out',
            variant: ButtonVariant.secondary,
            icon: Icons.logout,
          ),
          const SizedBox(height: 16),
          CustomButton(
            onPressed: () => _showDeleteAccountDialog(context),
            text: 'Delete Account',
            variant: ButtonVariant.text,
            icon: Icons.delete_forever,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion not implemented yet'),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}