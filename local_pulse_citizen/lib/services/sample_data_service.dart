import '../models/issue_model.dart';
import '../models/location_model.dart';
import 'issue_service.dart';
import 'auth_service.dart';

class SampleDataService {
  static Future<void> createSampleIssues() async {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) return;

    final sampleIssues = [
      {
        'title': 'Pothole on Main Street',
        'description': 'Large pothole causing damage to vehicles near the intersection of Main St and Oak Ave.',
        'category': 'Roads',
        'priority': 'High',
        'location': LocationModel(
          latitude: 37.7749 + (0.01 * (1 - 0.5)), // San Francisco area with slight variation
          longitude: -122.4194 + (0.01 * (1 - 0.5)),
          address: '123 Main Street, San Francisco, CA',
        ),
      },
      {
        'title': 'Broken Street Light',
        'description': 'Street light has been out for over a week, creating safety concerns for pedestrians.',
        'category': 'Electricity',
        'priority': 'Medium',
        'location': LocationModel(
          latitude: 37.7749 + (0.01 * (2 - 0.5)),
          longitude: -122.4194 + (0.01 * (2 - 0.5)),
          address: '456 Oak Avenue, San Francisco, CA',
        ),
      },
      {
        'title': 'Water Leak',
        'description': 'Water main leak causing flooding on the sidewalk and road.',
        'category': 'Water',
        'priority': 'Critical',
        'location': LocationModel(
          latitude: 37.7749 + (0.01 * (3 - 0.5)),
          longitude: -122.4194 + (0.01 * (3 - 0.5)),
          address: '789 Pine Street, San Francisco, CA',
        ),
      },
      {
        'title': 'Overflowing Trash Bin',
        'description': 'Public trash bin has been overflowing for several days, attracting pests.',
        'category': 'Waste',
        'priority': 'Low',
        'location': LocationModel(
          latitude: 37.7749 + (0.01 * (4 - 0.5)),
          longitude: -122.4194 + (0.01 * (4 - 0.5)),
          address: '321 Elm Street, San Francisco, CA',
        ),
      },
      {
        'title': 'Broken Sidewalk',
        'description': 'Cracked and uneven sidewalk creating tripping hazards for pedestrians.',
        'category': 'Safety',
        'priority': 'Medium',
        'location': LocationModel(
          latitude: 37.7749 + (0.01 * (5 - 0.5)),
          longitude: -122.4194 + (0.01 * (5 - 0.5)),
          address: '654 Maple Drive, San Francisco, CA',
        ),
      },
    ];

    for (final issueData in sampleIssues) {
      try {
        await IssueService.createIssue(
          title: issueData['title'] as String,
          description: issueData['description'] as String,
          category: issueData['category'] as String,
          priority: issueData['priority'] as String,
          location: issueData['location'] as LocationModel,
          images: null,
        );
        
        // Add a small delay to avoid overwhelming Firestore
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        print('Error creating sample issue: $e');
      }
    }
  }

  static Future<void> createSampleIssuesIfNeeded() async {
    try {
      final issues = await IssueService.getUserIssues();
      if (issues.isEmpty) {
        await createSampleIssues();
      }
    } catch (e) {
      print('Error checking for sample issues: $e');
    }
  }
}