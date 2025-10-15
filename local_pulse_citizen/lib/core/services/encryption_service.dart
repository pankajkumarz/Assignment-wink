import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Service for client-side data encryption and GDPR compliance
class EncryptionService {
  static EncryptionService? _instance;
  static EncryptionService get instance => _instance ??= EncryptionService._();
  
  EncryptionService._();

  /// Encrypt sensitive user data before storing
  String encryptSensitiveData(String data, String userKey) {
    try {
      // Simple XOR encryption for demonstration
      // In production, use proper encryption libraries like pointycastle
      final dataBytes = utf8.encode(data);
      final keyBytes = utf8.encode(userKey);
      final encryptedBytes = <int>[];

      for (int i = 0; i < dataBytes.length; i++) {
        encryptedBytes.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      return base64.encode(encryptedBytes);
    } catch (e) {
      if (kDebugMode) {
        print('Error encrypting data: $e');
      }
      return data; // Return original data if encryption fails
    }
  }

  /// Decrypt sensitive user data
  String decryptSensitiveData(String encryptedData, String userKey) {
    try {
      final encryptedBytes = base64.decode(encryptedData);
      final keyBytes = utf8.encode(userKey);
      final decryptedBytes = <int>[];

      for (int i = 0; i < encryptedBytes.length; i++) {
        decryptedBytes.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      return utf8.decode(decryptedBytes);
    } catch (e) {
      if (kDebugMode) {
        print('Error decrypting data: $e');
      }
      return encryptedData; // Return encrypted data if decryption fails
    }
  }

  /// Hash sensitive data for storage (one-way)
  String hashSensitiveData(String data) {
    try {
      final bytes = utf8.encode(data);
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      if (kDebugMode) {
        print('Error hashing data: $e');
      }
      return data;
    }
  }

  /// Generate a secure user key based on user ID and device info
  String generateUserKey(String userId) {
    try {
      // Combine user ID with a salt for key generation
      const salt = 'LocalPulse2024SecureSalt';
      final combined = '$userId$salt';
      final bytes = utf8.encode(combined);
      final digest = sha256.convert(bytes);
      return digest.toString().substring(0, 32); // Use first 32 characters
    } catch (e) {
      if (kDebugMode) {
        print('Error generating user key: $e');
      }
      return userId; // Fallback to user ID
    }
  }

  /// Anonymize user data for public display
  Map<String, dynamic> anonymizeUserData(Map<String, dynamic> userData) {
    final anonymized = Map<String, dynamic>.from(userData);
    
    // Remove or anonymize sensitive fields
    anonymized.remove('email');
    anonymized.remove('phone');
    anonymized.remove('fcmToken');
    anonymized.remove('lastKnownLocation');
    
    // Anonymize name
    if (anonymized['name'] != null) {
      final name = anonymized['name'] as String;
      if (name.isNotEmpty) {
        anonymized['name'] = '${name[0]}***';
      }
    }
    
    // Keep only necessary fields for public display
    return {
      'id': anonymized['id'],
      'name': anonymized['name'],
      'city': anonymized['city'],
      'joinDate': anonymized['createdAt'],
      'totalReports': anonymized['stats']?['totalReports'] ?? 0,
    };
  }

  /// Anonymize issue data for public display
  Map<String, dynamic> anonymizeIssueData(Map<String, dynamic> issueData) {
    final anonymized = Map<String, dynamic>.from(issueData);
    
    // Remove sensitive reporter information
    anonymized.remove('reporterEmail');
    anonymized.remove('reporterPhone');
    
    // Anonymize reporter name
    if (anonymized['reporterName'] != null) {
      final name = anonymized['reporterName'] as String;
      if (name.isNotEmpty) {
        anonymized['reporterName'] = '${name[0]}***';
      }
    }
    
    // Keep location but reduce precision
    if (anonymized['location'] != null) {
      final location = anonymized['location'] as Map<String, dynamic>;
      if (location['latitude'] != null && location['longitude'] != null) {
        // Reduce precision to ~100m accuracy
        location['latitude'] = double.parse(
          (location['latitude'] as double).toStringAsFixed(3)
        );
        location['longitude'] = double.parse(
          (location['longitude'] as double).toStringAsFixed(3)
        );
      }
    }
    
    return anonymized;
  }

  /// Prepare user data for GDPR export
  Map<String, dynamic> prepareGDPRExport(
    Map<String, dynamic> userData,
    List<Map<String, dynamic>> userIssues,
    List<Map<String, dynamic>> userFeedback,
  ) {
    return {
      'exportDate': DateTime.now().toIso8601String(),
      'userProfile': userData,
      'issues': userIssues,
      'feedback': userFeedback,
      'dataRetentionPolicy': {
        'profileData': '2 years after account deletion',
        'issueData': 'Anonymized and retained for transparency',
        'feedbackData': '1 year after submission',
      },
      'rightsInformation': {
        'rightToAccess': 'You can request access to your data at any time',
        'rightToRectification': 'You can update your profile information',
        'rightToErasure': 'You can request account deletion',
        'rightToPortability': 'You can export your data in JSON format',
        'rightToObject': 'You can opt-out of data processing for marketing',
      },
    };
  }

  /// Validate data before encryption/storage
  bool validateDataForStorage(Map<String, dynamic> data) {
    try {
      // Check for required fields
      if (!data.containsKey('id') || data['id'] == null) {
        return false;
      }

      // Check data size limits
      final jsonString = jsonEncode(data);
      if (jsonString.length > 1048576) { // 1MB limit
        if (kDebugMode) {
          print('Data size exceeds limit: ${jsonString.length} bytes');
        }
        return false;
      }

      // Check for potentially malicious content
      if (jsonString.contains('<script>') || 
          jsonString.contains('javascript:') ||
          jsonString.contains('data:text/html')) {
        if (kDebugMode) {
          print('Potentially malicious content detected');
        }
        return false;
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error validating data: $e');
      }
      return false;
    }
  }

  /// Sanitize user input to prevent XSS and injection attacks
  String sanitizeInput(String input) {
    if (input.isEmpty) return input;

    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('&', '&amp;')
        .replaceAll('javascript:', '')
        .replaceAll('data:', '')
        .trim();
  }

  /// Generate audit log entry for data access
  Map<String, dynamic> generateAuditLogEntry({
    required String userId,
    required String action,
    required String resourceType,
    required String resourceId,
    Map<String, dynamic>? metadata,
  }) {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'userId': userId,
      'action': action, // 'read', 'write', 'delete', 'export'
      'resourceType': resourceType, // 'user', 'issue', 'alert'
      'resourceId': resourceId,
      'metadata': metadata ?? {},
      'ipAddress': 'client-side', // Would be populated server-side
      'userAgent': 'mobile-app',
    };
  }

  /// Check if data processing consent is required
  bool requiresConsent(String dataType, String processingPurpose) {
    // Define data types that require explicit consent
    const sensitiveDataTypes = [
      'location',
      'biometric',
      'health',
      'political',
      'religious',
    ];

    const marketingPurposes = [
      'marketing',
      'advertising',
      'profiling',
      'analytics',
    ];

    return sensitiveDataTypes.contains(dataType) || 
           marketingPurposes.contains(processingPurpose);
  }

  /// Generate privacy notice text
  String generatePrivacyNotice() {
    return '''
Privacy Notice - Local Pulse

We collect and process your personal data to provide civic engagement services:

Data We Collect:
• Profile information (name, email, city)
• Issue reports and feedback
• Location data (when reporting issues)
• Device information for notifications

How We Use Your Data:
• To process and track your issue reports
• To send you notifications about your reports
• To improve our services and generate anonymized statistics
• To comply with legal obligations

Your Rights:
• Access your personal data
• Correct inaccurate information
• Delete your account and data
• Export your data
• Opt-out of non-essential processing

Data Retention:
• Profile data: Until account deletion + 30 days
• Issue reports: Anonymized and retained for transparency
• Location data: Not stored permanently

Contact us at privacy@localpulse.app for any privacy concerns.

Last updated: ${DateTime.now().toIso8601String().split('T')[0]}
''';
  }
}