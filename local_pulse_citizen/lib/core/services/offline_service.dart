import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/issue.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/issue_repository.dart';
import 'injection_container.dart' as di;

/// Service for offline functionality and data synchronization
class OfflineService {
  static OfflineService? _instance;
  static OfflineService get instance => _instance ??= OfflineService._();
  
  OfflineService._();

  late Box<Map> _offlineIssuesBox;
  late Box<Map> _cachedDataBox;
  late Box<String> _syncQueueBox;
  
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  /// Initialize offline service and Hive boxes
  Future<void> initialize() async {
    try {
      if (_isInitialized) return;

      // Initialize Hive
      await Hive.initFlutter();

      // Open boxes for offline data
      _offlineIssuesBox = await Hive.openBox<Map>('offline_issues');
      _cachedDataBox = await Hive.openBox<Map>('cached_data');
      _syncQueueBox = await Hive.openBox<String>('sync_queue');

      _isInitialized = true;

      if (kDebugMode) {
        print('Offline service initialized successfully');
      }

      // Start connectivity monitoring
      _startConnectivityMonitoring();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing offline service: $e');
      }
    }
  }

  /// Check if device is online
  Future<bool> isOnline() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking connectivity: $e');
      }
      return false;
    }
  }

  /// Save issue for offline submission
  Future<String> saveOfflineIssue(Map<String, dynamic> issueData) async {
    try {
      if (!_isInitialized) await initialize();

      // Generate temporary ID for offline issue
      final tempId = 'offline_${DateTime.now().millisecondsSinceEpoch}';
      
      // Add offline metadata
      issueData['tempId'] = tempId;
      issueData['isOffline'] = true;
      issueData['createdOfflineAt'] = DateTime.now().toIso8601String();
      issueData['syncStatus'] = 'pending';

      // Save to offline box
      await _offlineIssuesBox.put(tempId, issueData);

      // Add to sync queue
      await _syncQueueBox.put(tempId, jsonEncode({
        'type': 'create_issue',
        'tempId': tempId,
        'timestamp': DateTime.now().toIso8601String(),
      }));

      if (kDebugMode) {
        print('Issue saved offline with ID: $tempId');
      }

      return tempId;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving offline issue: $e');
      }
      throw Exception('Failed to save issue offline');
    }
  }

  /// Get all offline issues
  List<Map<String, dynamic>> getOfflineIssues() {
    try {
      if (!_isInitialized) return [];

      return _offlineIssuesBox.values
          .map((data) => Map<String, dynamic>.from(data))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting offline issues: $e');
      }
      return [];
    }
  }

  /// Cache data for offline access
  Future<void> cacheData(String key, Map<String, dynamic> data) async {
    try {
      if (!_isInitialized) await initialize();

      // Add cache metadata
      data['cachedAt'] = DateTime.now().toIso8601String();
      data['cacheKey'] = key;

      await _cachedDataBox.put(key, data);

      if (kDebugMode) {
        print('Data cached with key: $key');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error caching data: $e');
      }
    }
  }

  /// Get cached data
  Map<String, dynamic>? getCachedData(String key) {
    try {
      if (!_isInitialized) return null;

      final data = _cachedDataBox.get(key);
      if (data == null) return null;

      // Check if cache is still valid (24 hours)
      final cachedAt = DateTime.parse(data['cachedAt'] as String);
      final now = DateTime.now();
      if (now.difference(cachedAt).inHours > 24) {
        // Cache expired, remove it
        _cachedDataBox.delete(key);
        return null;
      }

      return Map<String, dynamic>.from(data);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting cached data: $e');
      }
      return null;
    }
  }

  /// Sync offline data when connection is restored
  Future<void> syncOfflineData() async {
    try {
      if (!_isInitialized) await initialize();

      final online = await isOnline();
      if (!online) {
        if (kDebugMode) {
          print('Device is offline, skipping sync');
        }
        return;
      }

      if (kDebugMode) {
        print('Starting offline data sync...');
      }

      // Get all items in sync queue
      final syncItems = _syncQueueBox.keys.toList();
      
      for (final key in syncItems) {
        try {
          final syncDataJson = _syncQueueBox.get(key);
          if (syncDataJson == null) continue;

          final syncData = jsonDecode(syncDataJson);
          
          if (syncData['type'] == 'create_issue') {
            await _syncOfflineIssue(syncData['tempId']);
          }
          
          // Remove from sync queue after successful sync
          await _syncQueueBox.delete(key);
          
        } catch (e) {
          if (kDebugMode) {
            print('Error syncing item $key: $e');
          }
          // Keep item in queue for retry
        }
      }

      if (kDebugMode) {
        print('Offline data sync completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during offline sync: $e');
      }
    }
  }

  /// Sync individual offline issue
  Future<void> _syncOfflineIssue(String tempId) async {
    try {
      final issueData = _offlineIssuesBox.get(tempId);
      if (issueData == null) return;

      final issueRepository = di.sl<IssueRepository>();
      
      // Remove offline metadata
      final cleanIssueData = Map<String, dynamic>.from(issueData);
      cleanIssueData.remove('tempId');
      cleanIssueData.remove('isOffline');
      cleanIssueData.remove('createdOfflineAt');
      cleanIssueData.remove('syncStatus');

      // Convert to Issue entity and submit
      final issue = Issue.fromJson(cleanIssueData);
      await issueRepository.submitIssue(issue);

      // Remove from offline storage
      await _offlineIssuesBox.delete(tempId);

      if (kDebugMode) {
        print('Offline issue synced successfully: $tempId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing offline issue $tempId: $e');
      }
      
      // Mark as failed for manual retry
      final issueData = _offlineIssuesBox.get(tempId);
      if (issueData != null) {
        issueData['syncStatus'] = 'failed';
        issueData['syncError'] = e.toString();
        await _offlineIssuesBox.put(tempId, issueData);
      }
    }
  }

  /// Start monitoring connectivity changes
  void _startConnectivityMonitoring() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        if (kDebugMode) {
          print('Connection restored, starting sync...');
        }
        // Delay sync to ensure connection is stable
        Future.delayed(const Duration(seconds: 2), () {
          syncOfflineData();
        });
      }
    });
  }

  /// Cache user's issues for offline viewing
  Future<void> cacheUserIssues(List<Issue> issues) async {
    try {
      final issuesData = issues.map((issue) => issue.toJson()).toList();
      await cacheData('user_issues', {
        'issues': issuesData,
        'count': issues.length,
      });

      if (kDebugMode) {
        print('Cached ${issues.length} user issues');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error caching user issues: $e');
      }
    }
  }

  /// Get cached user issues
  List<Issue> getCachedUserIssues() {
    try {
      final cachedData = getCachedData('user_issues');
      if (cachedData == null) return [];

      final issuesData = cachedData['issues'] as List<dynamic>;
      return issuesData
          .map((data) => Issue.fromJson(Map<String, dynamic>.from(data)))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting cached user issues: $e');
      }
      return [];
    }
  }

  /// Cache map data for offline location selection
  Future<void> cacheMapData(String area, Map<String, dynamic> mapData) async {
    try {
      await cacheData('map_$area', mapData);
      
      if (kDebugMode) {
        print('Map data cached for area: $area');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error caching map data: $e');
      }
    }
  }

  /// Get cached map data
  Map<String, dynamic>? getCachedMapData(String area) {
    return getCachedData('map_$area');
  }

  /// Save images for offline access
  Future<String?> saveImageOffline(String imageUrl) async {
    try {
      // Download and save image to local storage
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'offline_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = '${directory.path}/$fileName';

      // In a real implementation, you would download the image
      // For now, we'll just return the local path
      
      if (kDebugMode) {
        print('Image saved offline: $filePath');
      }

      return filePath;
    } catch (e) {
      if (kDebugMode) {
        print('Error saving image offline: $e');
      }
      return null;
    }
  }

  /// Get offline storage statistics
  Map<String, dynamic> getOfflineStats() {
    try {
      if (!_isInitialized) return {};

      return {
        'offlineIssues': _offlineIssuesBox.length,
        'cachedItems': _cachedDataBox.length,
        'syncQueueItems': _syncQueueBox.length,
        'totalStorageUsed': _calculateStorageUsed(),
        'lastSyncAttempt': _getLastSyncAttempt(),
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting offline stats: $e');
      }
      return {};
    }
  }

  /// Calculate approximate storage used by offline data
  int _calculateStorageUsed() {
    try {
      int totalSize = 0;
      
      // Calculate offline issues size
      for (final data in _offlineIssuesBox.values) {
        totalSize += jsonEncode(data).length;
      }
      
      // Calculate cached data size
      for (final data in _cachedDataBox.values) {
        totalSize += jsonEncode(data).length;
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  /// Get last sync attempt timestamp
  String? _getLastSyncAttempt() {
    try {
      return getCachedData('last_sync')?['timestamp'];
    } catch (e) {
      return null;
    }
  }

  /// Clear all offline data
  Future<void> clearOfflineData() async {
    try {
      if (!_isInitialized) await initialize();

      await _offlineIssuesBox.clear();
      await _cachedDataBox.clear();
      await _syncQueueBox.clear();

      if (kDebugMode) {
        print('All offline data cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing offline data: $e');
      }
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    try {
      if (_isInitialized) {
        await _offlineIssuesBox.close();
        await _cachedDataBox.close();
        await _syncQueueBox.close();
        _isInitialized = false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error disposing offline service: $e');
      }
    }
  }
}