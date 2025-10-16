import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/issue.dart';
import '../../domain/entities/geo_location.dart';

class IssueRepositoryImpl {
  final FirebaseFirestore _firestore;

  IssueRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Get real-time stream of all issues
  Stream<List<Issue>> watchAllIssues() {
    return _firestore
        .collection('issues')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return _issueFromFirestore(doc.id, data);
      }).toList();
    });
  }

  /// Get issues by status
  Stream<List<Issue>> watchIssuesByStatus(String status) {
    return _firestore
        .collection('issues')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return _issueFromFirestore(doc.id, data);
      }).toList();
    });
  }

  /// Get emergency/high priority issues
  Stream<List<Issue>> watchEmergencyIssues() {
    return _firestore
        .collection('issues')
        .where('priority', whereIn: ['high', 'emergency', 'critical'])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return _issueFromFirestore(doc.id, data);
      }).toList();
    });
  }

  /// Update issue status
  Future<void> updateIssueStatus(String issueId, String newStatus) async {
    await _firestore.collection('issues').doc(issueId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Assign issue to authority/department
  Future<void> assignIssue(String issueId, String assignedTo, String? department) async {
    await _firestore.collection('issues').doc(issueId).update({
      'assignedTo': assignedTo,
      'department': department,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Add comment to issue
  Future<void> addComment(String issueId, String comment, String authorId, String authorName) async {
    await _firestore
        .collection('issues')
        .doc(issueId)
        .collection('comments')
        .add({
      'comment': comment,
      'authorId': authorId,
      'authorName': authorName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get issue statistics
  Future<Map<String, int>> getIssueStatistics() async {
    final allIssues = await _firestore.collection('issues').get();
    
    final stats = <String, int>{
      'total': allIssues.docs.length,
      'submitted': 0,
      'acknowledged': 0,
      'in_progress': 0,
      'resolved': 0,
      'closed': 0,
      'rejected': 0,
    };

    for (final doc in allIssues.docs) {
      final status = doc.data()['status'] as String? ?? 'submitted';
      stats[status] = (stats[status] ?? 0) + 1;
    }

    return stats;
  }

  /// Convert Firestore document to Issue entity
  Issue _issueFromFirestore(String id, Map<String, dynamic> data) {
    return Issue(
      id: id,
      title: data['title'] ?? 'Unknown Issue',
      description: data['description'] ?? 'No description provided',
      category: data['category'] ?? 'general',
      subcategory: data['subcategory'] ?? 'other',
      status: data['status'] ?? 'submitted',
      priority: data['priority'] ?? 'medium',
      location: GeoLocation(
        latitude: (data['location']?['latitude'] ?? 0.0).toDouble(),
        longitude: (data['location']?['longitude'] ?? 0.0).toDouble(),
        address: data['location']?['address'] ?? 'Unknown Address',
        city: data['location']?['city'] ?? 'Unknown City',
      ),
      images: List<String>.from(data['images'] ?? []),
      reporterId: data['reporterId'] ?? 'unknown',
      assignedTo: data['assignedTo'],
      department: data['department'],
      estimatedResolution: data['estimatedResolution']?.toDate(),
      actualResolution: data['actualResolution']?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}