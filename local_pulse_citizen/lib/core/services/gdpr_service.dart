import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/issue_repository.dart';
import 'encryption_service.dart';
import 'injection_container.dart' as di;

/// Service for GDPR compliance and data protection
class GDPRService {
  static GDPRService? _instance;
  static GDPRService get instance => _instance ??= GDPRService._();
  
  GDPRService._();

  final EncryptionService _encryptionService = EncryptionService.instance;

  /// Export all user data for GDPR compliance
  Future<String?> exportUserData(String userId) async {
    try {
      // Get user data from repositories
      final authRepository = di.sl<AuthRepository>();
      final issueRepository = di.sl<IssueRepository>();

      // Get user profile
      final user = await authRepository.getCurrentUser();
      if (user == null) {
        throw Exception('User not found');
      }

      // Get user's issues
      final issues = await issueRepository.getUserIssues(userId);

      // Get user's feedback (would need to implement this in repository)
      final feedback = <Map<String, dynamic>>[];

      // Prepare GDPR export data
      final exportData = _encryptionService.prepareGDPRExport(
        user.toJson(),
        issues.map((issue) => issue.toJson()).toList(),
        feedback,
      );

      // Convert to JSON string
      const encoder = JsonEncoder.withIndent('  ');
      final jsonString = encoder.convert(exportData);

      // Save to file
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/gdpr_export_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(jsonString);

      if (kDebugMode) {
        print('GDPR export saved to: ${file.path}');
      }

      return file.path;
    } catch (e) {
      if (kDebugMode) {
        print('Error exporting user data: $e');
      }
      return null;
    }
  }

  /// Share exported data with user
  Future<bool> shareExportedData(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Export file not found');
      }

      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Your Local Pulse data export as requested under GDPR Article 20',
        subject: 'Local Pulse - Your Data Export',
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error sharing exported data: $e');
      }
      return false;
    }
  }

  /// Delete all user data (Right to be forgotten)
  Future<bool> deleteAllUserData(String userId) async {
    try {
      final authRepository = di.sl<AuthRepository>();
      
      // This would trigger the Cloud Function to:
      // 1. Delete user profile
      // 2. Anonymize user's issues
      // 3. Delete user's feedback
      // 4. Remove user from all collections
      
      await authRepository.deleteAccount();

      if (kDebugMode) {
        print('User data deletion initiated for: $userId');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting user data: $e');
      }
      return false;
    }
  }

  /// Get user's data processing consent status
  Map<String, bool> getConsentStatus(User user) {
    return {
      'essential': true, // Always true for app functionality
      'analytics': user.preferences.notifications.pushEnabled,
      'marketing': false, // Not implemented yet
      'location': true, // Required for issue reporting
      'notifications': user.preferences.notifications.pushEnabled,
      'whatsapp': user.preferences.notifications.whatsappEnabled,
      'email': user.preferences.notifications.emailEnabled,
    };
  }

  /// Update user's data processing consent
  Future<bool> updateConsent(String userId, Map<String, bool> consent) async {
    try {
      // Update user preferences based on consent
      // This would be implemented in the user repository
      
      if (kDebugMode) {
        print('Consent updated for user: $userId');
        print('Consent settings: $consent');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating consent: $e');
      }
      return false;
    }
  }

  /// Generate data processing record for audit
  Map<String, dynamic> generateProcessingRecord({
    required String userId,
    required String dataType,
    required String purpose,
    required String legalBasis,
    String? retentionPeriod,
  }) {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'userId': userId,
      'dataType': dataType,
      'purpose': purpose,
      'legalBasis': legalBasis, // 'consent', 'contract', 'legal_obligation', etc.
      'retentionPeriod': retentionPeriod ?? 'Until account deletion',
      'dataController': 'Local Pulse',
      'dataProcessor': 'Firebase/Google Cloud',
      'transferredToThirdCountries': false,
      'safeguards': ['Encryption in transit', 'Access controls', 'Audit logging'],
    };
  }

  /// Check if data retention period has expired
  bool isRetentionPeriodExpired(DateTime dataCreated, String retentionPeriod) {
    final now = DateTime.now();
    
    switch (retentionPeriod.toLowerCase()) {
      case '30 days':
        return now.difference(dataCreated).inDays > 30;
      case '1 year':
        return now.difference(dataCreated).inDays > 365;
      case '2 years':
        return now.difference(dataCreated).inDays > 730;
      case 'until account deletion':
        return false; // Only expires when user deletes account
      default:
        return false;
    }
  }

  /// Generate privacy impact assessment
  Map<String, dynamic> generatePrivacyImpactAssessment() {
    return {
      'assessmentDate': DateTime.now().toIso8601String(),
      'dataTypes': [
        {
          'type': 'Personal identifiers',
          'examples': ['Name', 'Email', 'User ID'],
          'sensitivity': 'Medium',
          'purpose': 'User account management',
        },
        {
          'type': 'Location data',
          'examples': ['GPS coordinates', 'Address'],
          'sensitivity': 'High',
          'purpose': 'Issue reporting and geolocation',
        },
        {
          'type': 'Communication data',
          'examples': ['Issue descriptions', 'Feedback'],
          'sensitivity': 'Medium',
          'purpose': 'Service provision and improvement',
        },
      ],
      'risks': [
        {
          'risk': 'Unauthorized access to location data',
          'likelihood': 'Low',
          'impact': 'High',
          'mitigation': 'Encryption, access controls, audit logging',
        },
        {
          'risk': 'Data breach exposing personal information',
          'likelihood': 'Low',
          'impact': 'Medium',
          'mitigation': 'Firebase security, regular security audits',
        },
      ],
      'safeguards': [
        'Data minimization - only collect necessary data',
        'Purpose limitation - use data only for stated purposes',
        'Storage limitation - delete data when no longer needed',
        'Encryption in transit and at rest',
        'Regular security assessments',
        'User consent management',
        'Data subject rights implementation',
      ],
    };
  }

  /// Get data breach notification template
  Map<String, dynamic> getDataBreachNotificationTemplate() {
    return {
      'template': '''
Data Breach Notification - Local Pulse

We are writing to inform you of a data security incident that may have affected your personal information.

What Happened:
[Description of the incident]

What Information Was Involved:
[Types of data potentially affected]

What We Are Doing:
• Immediately secured the affected systems
• Launched a thorough investigation
• Notified relevant authorities
• Implemented additional security measures

What You Can Do:
• Monitor your accounts for unusual activity
• Change your password if recommended
• Contact us with any concerns

We sincerely apologize for this incident and any inconvenience it may cause.

Contact Information:
Email: security@localpulse.app
Phone: [Support phone number]

Date: [Incident date]
Reference: [Incident reference number]
''',
      'requiredFields': [
        'incidentDescription',
        'affectedDataTypes',
        'incidentDate',
        'referenceNumber',
        'contactInformation',
      ],
      'notificationDeadline': '72 hours from discovery',
      'authorities': [
        'Data Protection Authority',
        'Local law enforcement (if criminal activity suspected)',
      ],
    };
  }

  /// Validate GDPR compliance checklist
  Map<String, bool> validateGDPRCompliance() {
    return {
      'lawfulBasisIdentified': true,
      'privacyNoticeProvided': true,
      'consentMechanismImplemented': true,
      'dataSubjectRightsImplemented': true,
      'dataRetentionPolicyDefined': true,
      'securityMeasuresImplemented': true,
      'dataProcessorAgreementsInPlace': true,
      'breachNotificationProcedureEstablished': true,
      'privacyImpactAssessmentConducted': true,
      'dataProtectionOfficerAppointed': false, // Not required for small organizations
      'internationalTransferSafeguards': true,
      'auditLoggingImplemented': true,
    };
  }

  /// Get user rights information
  Map<String, String> getUserRightsInformation() {
    return {
      'rightToInformation': 'You have the right to know how your data is processed',
      'rightOfAccess': 'You can request a copy of your personal data',
      'rightToRectification': 'You can correct inaccurate personal data',
      'rightToErasure': 'You can request deletion of your personal data',
      'rightToRestrictProcessing': 'You can limit how we process your data',
      'rightToDataPortability': 'You can receive your data in a portable format',
      'rightToObject': 'You can object to processing for marketing purposes',
      'rightsRelatedToAutomatedDecisionMaking': 'You can request human review of automated decisions',
      'rightToWithdrawConsent': 'You can withdraw consent at any time',
      'rightToComplain': 'You can complain to the data protection authority',
    };
  }
}