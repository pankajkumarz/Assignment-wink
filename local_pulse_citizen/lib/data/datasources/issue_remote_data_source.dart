import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../../core/error/exceptions.dart';
import '../../core/constants/app_constants.dart';
import '../models/issue_model.dart';
import '../../domain/entities/geo_location.dart';

abstract class IssueRemoteDataSource {
  Future<String> createIssue({required IssueModel issue});
  Future<IssueModel> getIssueById({required String issueId});
  Future<void> updateIssue({required IssueModel issue});
  Future<void> deleteIssue({required String issueId});
  Future<List<IssueModel>> getIssuesByReporter({required String reporterId});
  Future<List<IssueModel>> getIssuesByStatus({required String status});
  Future<List<IssueModel>> getIssuesByCategory({required String category});
  Future<List<IssueModel>> getIssuesByCity({required String city});
  Future<List<IssueModel>> getIssuesNearLocation({
    required GeoLocation location,
    required double radiusInKm,
  });
  Stream<List<IssueModel>> watchIssuesByReporter({required String reporterId});
  Stream<List<IssueModel>> watchPublicIssues();
  Stream<IssueModel> watchIssue({required String issueId});
  Future<List<String>> uploadImages({
    required String issueId,
    required List<File> images,
  });
}

class IssueRemoteDataSourceImpl implements IssueRemoteDataSource {
  const IssueRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  @override
  Future<String> createIssue({required IssueModel issue}) async {
    try {
      final docRef = _firestore.collection(AppConstants.issuesCollection).doc();
      final issueWithId = IssueModel.fromEntity(issue.copyWith(id: docRef.id));
      
      await docRef.set(issueWithId.toMap());
      return docRef.id;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<IssueModel> getIssueById({required String issueId}) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.issuesCollection)
          .doc(issueId)
          .get();

      if (!doc.exists) {
        throw const ServerException('Issue not found');
      }

      return IssueModel.fromMap(doc.data()!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> updateIssue({required IssueModel issue}) async {
    try {
      await _firestore
          .collection(AppConstants.issuesCollection)
          .doc(issue.id)
          .update(issue.toMap());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteIssue({required String issueId}) async {
    try {
      await _firestore
          .collection(AppConstants.issuesCollection)
          .doc(issueId)
          .delete();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<IssueModel>> getIssuesByReporter({required String reporterId}) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.issuesCollection)
          .where('reporterId', isEqualTo: reporterId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => IssueModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<IssueModel>> getIssuesByStatus({required String status}) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.issuesCollection)
          .where('status', isEqualTo: status)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => IssueModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<IssueModel>> getIssuesByCategory({required String category}) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.issuesCollection)
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => IssueModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<IssueModel>> getIssuesByCity({required String city}) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.issuesCollection)
          .where('location.city', isEqualTo: city)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => IssueModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<IssueModel>> getIssuesNearLocation({
    required GeoLocation location,
    required double radiusInKm,
  }) async {
    try {
      // For simplicity, we'll get all issues in the same city
      // In a production app, you'd use geohash or GeoFlutterFire for proper geospatial queries
      final querySnapshot = await _firestore
          .collection(AppConstants.issuesCollection)
          .where('location.city', isEqualTo: location.city)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => IssueModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<List<IssueModel>> watchIssuesByReporter({required String reporterId}) {
    try {
      return _firestore
          .collection(AppConstants.issuesCollection)
          .where('reporterId', isEqualTo: reporterId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => IssueModel.fromMap(doc.data()))
              .toList());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<List<IssueModel>> watchPublicIssues() {
    try {
      return _firestore
          .collection(AppConstants.issuesCollection)
          .orderBy('createdAt', descending: true)
          .limit(100) // Limit for performance
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => IssueModel.fromMap(doc.data()))
              .toList());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Stream<IssueModel> watchIssue({required String issueId}) {
    try {
      return _firestore
          .collection(AppConstants.issuesCollection)
          .doc(issueId)
          .snapshots()
          .map((doc) {
        if (!doc.exists) {
          throw const ServerException('Issue not found');
        }
        return IssueModel.fromMap(doc.data()!);
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<String>> uploadImages({
    required String issueId,
    required List<File> images,
  }) async {
    try {
      final List<String> imageUrls = [];
      
      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        final fileName = 'image_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = _storage.ref().child('issues/$issueId/$fileName');
        
        final uploadTask = await ref.putFile(file);
        final downloadUrl = await uploadTask.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }
      
      return imageUrls;
    } catch (e) {
      throw StorageException(e.toString());
    }
  }
}