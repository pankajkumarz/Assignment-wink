import 'package:cloud_firestore/cloud_firestore.dart';

class DemoDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add sample issues to demonstrate the connection between citizen and authority apps
  static Future<void> addSampleIssues() async {
    try {
      // Check if issues already exist
      final existingIssues = await _firestore.collection('issues').limit(1).get();
      if (existingIssues.docs.isNotEmpty) {
        print('Issues already exist in database');
        return;
      }

      // Add sample issues
      final sampleIssues = [
        {
          'title': 'Broken Street Light on Main Road',
          'description': 'The street light near the bus stop has been broken for 3 days. It\'s causing safety issues for pedestrians at night.',
          'category': 'infrastructure',
          'subcategory': 'lighting',
          'status': 'submitted',
          'priority': 'medium',
          'location': {
            'latitude': 28.6139,
            'longitude': 77.2090,
            'address': 'Main Road, Near Bus Stop, Connaught Place',
            'city': 'New Delhi',
          },
          'images': [],
          'reporterId': 'citizen_user_001',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'title': 'Large Pothole on Highway',
          'description': 'There is a large pothole on the highway that is causing damage to vehicles. Multiple citizens have complained about this.',
          'category': 'infrastructure',
          'subcategory': 'roads',
          'status': 'acknowledged',
          'priority': 'high',
          'location': {
            'latitude': 28.6129,
            'longitude': 77.2080,
            'address': 'Highway 1, KM 15, Near Toll Plaza',
            'city': 'New Delhi',
          },
          'images': [],
          'reporterId': 'citizen_user_002',
          'assignedTo': 'road_maintenance_dept',
          'department': 'Public Works Department',
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 6))),
          'updatedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 2))),
        },
        {
          'title': 'Water Leakage in Residential Area',
          'description': 'Water pipe has burst in the residential area causing water wastage and flooding on the road.',
          'category': 'utilities',
          'subcategory': 'water',
          'status': 'in_progress',
          'priority': 'high',
          'location': {
            'latitude': 28.6149,
            'longitude': 77.2100,
            'address': 'Residential Complex, Block A, Sector 15',
            'city': 'New Delhi',
          },
          'images': [],
          'reporterId': 'citizen_user_003',
          'assignedTo': 'water_dept_team_1',
          'department': 'Water Supply Department',
          'estimatedResolution': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 12))),
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 12))),
          'updatedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 1))),
        },
        {
          'title': 'Garbage Not Collected for 3 Days',
          'description': 'Garbage has not been collected from our area for the past 3 days. It\'s creating hygiene issues.',
          'category': 'sanitation',
          'subcategory': 'waste_management',
          'status': 'resolved',
          'priority': 'medium',
          'location': {
            'latitude': 28.6119,
            'longitude': 77.2070,
            'address': 'Green Park Extension, Block B',
            'city': 'New Delhi',
          },
          'images': [],
          'reporterId': 'citizen_user_004',
          'assignedTo': 'sanitation_team_2',
          'department': 'Sanitation Department',
          'actualResolution': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 4))),
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 2))),
          'updatedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 4))),
        },
        {
          'title': 'Emergency: Gas Leak Reported',
          'description': 'URGENT: Gas leak reported in the commercial area. Immediate attention required for safety.',
          'category': 'emergency',
          'subcategory': 'gas_leak',
          'status': 'submitted',
          'priority': 'emergency',
          'location': {
            'latitude': 28.6159,
            'longitude': 77.2110,
            'address': 'Commercial Complex, Shop No. 45, Karol Bagh',
            'city': 'New Delhi',
          },
          'images': [],
          'reporterId': 'citizen_user_005',
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 15))),
          'updatedAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 15))),
        },
      ];

      // Add each issue to Firestore
      for (final issue in sampleIssues) {
        await _firestore.collection('issues').add(issue);
      }

      print('Sample issues added successfully!');
    } catch (e) {
      print('Error adding sample issues: $e');
    }
  }

  /// Add sample user data
  static Future<void> addSampleUsers() async {
    try {
      final sampleUsers = [
        {
          'name': 'John Doe',
          'email': 'john.doe@example.com',
          'phone': '+91-9876543210',
          'role': 'citizen',
          'city': 'New Delhi',
          'address': 'Connaught Place, New Delhi',
          'isVerified': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        {
          'name': 'Authority Officer',
          'email': 'officer@localpulse.gov',
          'phone': '+91-9876543211',
          'role': 'authority',
          'city': 'New Delhi',
          'department': 'Municipal Corporation',
          'isVerified': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      ];

      for (final user in sampleUsers) {
        await _firestore.collection('users').add(user);
      }

      print('Sample users added successfully!');
    } catch (e) {
      print('Error adding sample users: $e');
    }
  }
}