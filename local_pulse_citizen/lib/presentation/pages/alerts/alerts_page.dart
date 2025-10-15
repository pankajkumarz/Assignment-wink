import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/injection_container.dart' as di;
import '../../../domain/entities/alert.dart';
import '../../bloc/auth/auth_bloc.dart';

class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Civic Alerts & News'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showFilterDialog(context),
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthSuccess) {
            return _buildAlertsContent(context, state.user.city);
          } else {
            return const Center(
              child: Text('Please sign in to view alerts'),
            );
          }
        },
      ),
    );
  }

  Widget _buildAlertsContent(BuildContext context, String userCity) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coming Soon Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.upcoming,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Civic Alerts & News',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Coming Soon!',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Stay tuned for real-time civic alerts, road construction updates, and community news for $userCity.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Feature Preview Cards
          Text(
            'What\'s Coming',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Emergency Alerts Preview
          _buildFeaturePreviewCard(
            context,
            icon: Icons.warning_amber,
            iconColor: Colors.red,
            title: 'Emergency Alerts',
            description: 'Receive instant notifications about emergencies, natural disasters, and safety alerts in your area.',
            features: [
              'Real-time emergency notifications',
              'Location-based alert filtering',
              'Priority alert system',
              'Multi-channel delivery (Push, WhatsApp)',
            ],
          ),
          const SizedBox(height: 16),

          // Road Construction Preview
          _buildFeaturePreviewCard(
            context,
            icon: Icons.construction,
            iconColor: Colors.orange,
            title: 'Road Construction Updates',
            description: 'Get notified about road closures, construction work, and alternate route suggestions.',
            features: [
              'Real-time road closure updates',
              'Construction timeline information',
              'Alternate route suggestions',
              'Traffic impact notifications',
            ],
          ),
          const SizedBox(height: 16),

          // Civic News Preview
          _buildFeaturePreviewCard(
            context,
            icon: Icons.newspaper,
            iconColor: Colors.blue,
            title: 'Community News',
            description: 'Stay informed about local government decisions, community events, and civic developments.',
            features: [
              'Local government announcements',
              'Community event notifications',
              'Policy change updates',
              'Public meeting schedules',
            ],
          ),
          const SizedBox(height: 24),

          // Timeline Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Development Timeline',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTimelineItem(
                    context,
                    'Phase 1: Alert Infrastructure',
                    'Setting up alert delivery system and database',
                    isCompleted: false,
                    isActive: true,
                  ),
                  _buildTimelineItem(
                    context,
                    'Phase 2: Emergency Alerts',
                    'Implementing emergency alert notifications',
                    isCompleted: false,
                    isActive: false,
                  ),
                  _buildTimelineItem(
                    context,
                    'Phase 3: Road Construction Updates',
                    'Adding road closure and construction alerts',
                    isCompleted: false,
                    isActive: false,
                  ),
                  _buildTimelineItem(
                    context,
                    'Phase 4: Civic News Integration',
                    'Full civic news and community updates',
                    isCompleted: false,
                    isActive: false,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Notification Preferences
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get Notified When Available',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We\'ll notify you when civic alerts and news features become available.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('You\'ll be notified when alerts are available!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications_active),
                    label: const Text('Notify Me'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePreviewCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required List<String> features,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ...features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    String title,
    String description, {
    required bool isCompleted,
    required bool isActive,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.green
                    : isActive
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                shape: BoxShape.circle,
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Colors.grey.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alert Filters'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Filter options will be available when alerts are launched.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}