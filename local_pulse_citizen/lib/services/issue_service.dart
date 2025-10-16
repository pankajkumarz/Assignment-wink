import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import '../models/issue_model.dart';
import '../models/location_model.dart';
import 'auth_service.dart';

class IssueService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const Uuid _uuid = Uuid();

  // Create new issue
  static Future<String> createIssue({
    required String title,
    required String description,
    required String category,
    required String priority,
    required LocationModel location,
    List<File>? images,
  }) async {
    try {
      final user = AuthService.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Upload images if any
      List<String> imageUrls = [];
      if (images != null && images.isNotEmpty) {
        imageUrls = await _uploadImages(images);
      }

      // Create issue
      final issueId = _uuid.v4();
      final issue = IssueModel(
        id: issueId,
        title: title,
        description: description,
        category: category,
        priority: priority,
        status: 'submitted',
        reporterId: user.uid,
        location: location,
        imageUrls: imageUrls,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      await _firestore
          .collection('issues')
          .doc(issueId)
          .set(issue.toMap());

      return issueId;
    } catch (e) {
      print('Create issue error: $e');
      rethrow;
    }
  }

  // Upload images to Firebase Storage
  static Future<List<String>> _uploadImages(List<File> images) async {
    List<String> urls = [];
    
    for (File image in images) {
      try {
        final fileName = '${_uuid.v4()}.jpg';
        final ref = _storage.ref().child('issue_images/$fileName');
        
        await ref.putFile(image);
        final url = await ref.getDownloadURL();
        urls.add(url);
      } catch (e) {
        print('Image upload error: $e');
      }
    }
    
    return urls;
  }

  // Get user's issues
  static Future<List<IssueModel>> getUserIssues() async {
    try {
      final user = AuthService.currentUser;
      if (user == null) return _getSampleUserIssues();

      final querySnapshot = await _firestore
          .collection('issues')
          .where('reporterId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      final firebaseIssues = querySnapshot.docs
          .map((doc) => IssueModel.fromMap(doc.data()))
          .toList();

      // If no Firebase issues, return sample data for demo
      if (firebaseIssues.isEmpty) {
        return _getSampleUserIssues();
      }

      return firebaseIssues;
    } catch (e) {
      print('Get user issues error: $e');
      // Return sample data on error for demo purposes
      return _getSampleUserIssues();
    }
  }

  // Sample user issues for demo
  static List<IssueModel> _getSampleUserIssues() {
    final now = DateTime.now();
    return [
      IssueModel(
        id: 'user_issue_1',
        title: 'Pothole on Main Street',
        description: 'Large pothole causing damage to vehicles near the intersection of Main St and Oak Ave.',
        category: 'Roads',
        priority: 'High',
        status: 'submitted',
        reporterId: 'current_user',
        location: LocationModel(
          latitude: 40.7128,
          longitude: -74.0060,
          address: 'Main Street & Oak Avenue, Downtown',
        ),
        imageUrls: [],
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      IssueModel(
        id: 'user_issue_2',
        title: 'Broken Street Light',
        description: 'Street light has been out for 3 days, making the area unsafe at night.',
        category: 'Electricity',
        priority: 'Medium',
        status: 'acknowledged',
        reporterId: 'current_user',
        location: LocationModel(
          latitude: 40.7589,
          longitude: -73.9851,
          address: 'Pine Street, Residential Area',
        ),
        imageUrls: ['image1.jpg'],
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(hours: 6)),
      ),
      IssueModel(
        id: 'user_issue_3',
        title: 'Water Leak',
        description: 'Water main leak causing flooding on the sidewalk.',
        category: 'Water',
        priority: 'Critical',
        status: 'in_progress',
        reporterId: 'current_user',
        location: LocationModel(
          latitude: 40.7505,
          longitude: -73.9934,
          address: 'Elm Street, Near Park',
        ),
        imageUrls: ['image2.jpg', 'image3.jpg'],
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(hours: 12)),
      ),
    ];
  }

  // Get nearby issues
  static Future<List<IssueModel>> getNearbyIssues({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) async {
    try {
      // Note: This is a simplified version. For production, use GeoFlutterFire
      final querySnapshot = await _firestore
          .collection('issues')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs
          .map((doc) => IssueModel.fromMap(doc.data()))
          .where((issue) {
            // Simple distance check (not accurate for production)
            final distance = _calculateDistance(
              latitude,
              longitude,
              issue.location.latitude,
              issue.location.longitude,
            );
            return distance <= radiusKm;
          })
          .toList();
    } catch (e) {
      print('Get nearby issues error: $e');
      return [];
    }
  }

  // Simple distance calculation (Haversine formula)
  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    
    double c = 2 * asin(sqrt(a));
    
    return earthRadius * c;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // Get issue by ID
  static Future<IssueModel?> getIssueById(String issueId) async {
    try {
      final doc = await _firestore.collection('issues').doc(issueId).get();
      if (doc.exists) {
        return IssueModel.fromMap(doc.data()!);
      }
    } catch (e) {
      print('Get issue error: $e');
    }
    return null;
  }

  // Update issue status (for authorities)
  static Future<void> updateIssueStatus(String issueId, String status) async {
    try {
      await _firestore.collection('issues').doc(issueId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Update issue status error: $e');
      rethrow;
    }
  }
}