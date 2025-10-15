import 'package:flutter/foundation.dart';
import 'whatsapp_service.dart';
import 'notification_service.dart';

/// Service to handle communication preferences and fallback mechanisms
class CommunicationService {
  static CommunicationService? _instance;
  static CommunicationService get instance => _instance ??= CommunicationService._();
  
  CommunicationService._();

  final WhatsAppService _whatsappService = WhatsAppService.instance;
  final NotificationService _notificationService = NotificationService.instance;

  /// Send issue status update with fallback mechanism
  Future<bool> sendIssueStatusUpdate({
    required String issueId,
    required String title,
    required String oldStatus,
    required String newStatus,
    String? comment,
    String? trackingUrl,
    required bool whatsappEnabled,
    required bool pushEnabled,
    String? phoneNumber,
  }) async {
    bool success = false;

    // Try WhatsApp first if enabled and phone number is available
    if (whatsappEnabled && phoneNumber != null && phoneNumber.isNotEmpty) {
      try {
        if (await _whatsappService.isWhatsAppInstalled()) {
          success = await _whatsappService.shareStatusUpdate(
            issueId: issueId,
            title: title,
            oldStatus: oldStatus,
            newStatus: newStatus,
            comment: comment,
            trackingUrl: trackingUrl,
          );
          
          if (success) {
            if (kDebugMode) {
              print('Status update sent via WhatsApp successfully');
            }
            return true;
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('WhatsApp sending failed: $e');
        }
      }
    }

    // Fallback to push notification if WhatsApp failed or not enabled
    if (pushEnabled) {
      try {
        await _notificationService.showNotification(
          title: 'Issue Update: $title',
          body: _buildStatusUpdateMessage(oldStatus, newStatus, comment),
          payload: issueId,
        );
        success = true;
        
        if (kDebugMode) {
          print('Status update sent via push notification');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Push notification failed: $e');
        }
      }
    }

    return success;
  }

  /// Send emergency alert with all available channels
  Future<bool> sendEmergencyAlert({
    required String alertTitle,
    required String alertMessage,
    required String location,
    required bool whatsappEnabled,
    required bool pushEnabled,
    String? phoneNumber,
  }) async {
    bool anySuccess = false;

    // Send via WhatsApp if enabled
    if (whatsappEnabled && phoneNumber != null && phoneNumber.isNotEmpty) {
      try {
        final message = _whatsappService.buildEmergencyAlertMessage(
          alertTitle: alertTitle,
          alertMessage: alertMessage,
          location: location,
        );
        
        if (await _whatsappService.sendNotificationMessage(
          phoneNumber: phoneNumber,
          message: message,
        )) {
          anySuccess = true;
          if (kDebugMode) {
            print('Emergency alert sent via WhatsApp');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('WhatsApp emergency alert failed: $e');
        }
      }
    }

    // Always send push notification for emergencies
    if (pushEnabled) {
      try {
        await _notificationService.showNotification(
          title: '🚨 Emergency Alert: $alertTitle',
          body: '$alertMessage\nLocation: $location',
          payload: 'emergency_alert',
        );
        anySuccess = true;
        
        if (kDebugMode) {
          print('Emergency alert sent via push notification');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Push notification for emergency failed: $e');
        }
      }
    }

    return anySuccess;
  }

  /// Send civic news update
  Future<bool> sendCivicNewsUpdate({
    required String newsTitle,
    required String newsContent,
    required String category,
    required bool whatsappEnabled,
    required bool pushEnabled,
    String? phoneNumber,
  }) async {
    bool success = false;

    // Try WhatsApp first if enabled
    if (whatsappEnabled && phoneNumber != null && phoneNumber.isNotEmpty) {
      try {
        final message = _whatsappService.buildCivicNewsMessage(
          newsTitle: newsTitle,
          newsContent: newsContent,
          category: category,
        );
        
        success = await _whatsappService.sendNotificationMessage(
          phoneNumber: phoneNumber,
          message: message,
        );
        
        if (success) {
          if (kDebugMode) {
            print('Civic news sent via WhatsApp');
          }
          return true;
        }
      } catch (e) {
        if (kDebugMode) {
          print('WhatsApp civic news failed: $e');
        }
      }
    }

    // Fallback to push notification
    if (pushEnabled) {
      try {
        await _notificationService.showNotification(
          title: '📰 $category: $newsTitle',
          body: newsContent,
          payload: 'civic_news',
        );
        success = true;
        
        if (kDebugMode) {
          print('Civic news sent via push notification');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Push notification for civic news failed: $e');
        }
      }
    }

    return success;
  }

  /// Test communication channels
  Future<Map<String, bool>> testCommunicationChannels({
    required bool whatsappEnabled,
    required bool pushEnabled,
    String? phoneNumber,
  }) async {
    final results = <String, bool>{};

    // Test WhatsApp
    if (whatsappEnabled) {
      try {
        results['whatsapp_installed'] = await _whatsappService.isWhatsAppInstalled();
        results['whatsapp_phone_available'] = phoneNumber != null && phoneNumber.isNotEmpty;
      } catch (e) {
        results['whatsapp_installed'] = false;
        results['whatsapp_phone_available'] = false;
      }
    } else {
      results['whatsapp_installed'] = false;
      results['whatsapp_phone_available'] = false;
    }

    // Test Push Notifications
    if (pushEnabled) {
      try {
        // Test by checking if notification service is initialized
        results['push_notifications'] = _notificationService.isInitialized;
      } catch (e) {
        results['push_notifications'] = false;
      }
    } else {
      results['push_notifications'] = false;
    }

    return results;
  }

  /// Get recommended communication method based on preferences and availability
  Future<String> getRecommendedCommunicationMethod({
    required bool whatsappEnabled,
    required bool pushEnabled,
    String? phoneNumber,
  }) async {
    final testResults = await testCommunicationChannels(
      whatsappEnabled: whatsappEnabled,
      pushEnabled: pushEnabled,
      phoneNumber: phoneNumber,
    );

    if (whatsappEnabled && 
        testResults['whatsapp_installed'] == true && 
        testResults['whatsapp_phone_available'] == true) {
      return 'WhatsApp (Primary)';
    } else if (pushEnabled && testResults['push_notifications'] == true) {
      return 'Push Notifications';
    } else {
      return 'No communication method available';
    }
  }

  /// Build status update message for push notifications
  String _buildStatusUpdateMessage(String oldStatus, String newStatus, String? comment) {
    final buffer = StringBuffer();
    buffer.write('Status changed from ${_formatStatus(oldStatus)} to ${_formatStatus(newStatus)}');
    
    if (comment != null && comment.isNotEmpty) {
      buffer.write('\n\nComment: $comment');
    }
    
    return buffer.toString();
  }

  /// Format status for display
  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return 'Submitted';
      case 'acknowledged':
        return 'Acknowledged';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  /// Get communication preferences summary
  Map<String, dynamic> getCommunicationPreferencesSummary({
    required bool whatsappEnabled,
    required bool pushEnabled,
    required bool emailEnabled,
    required bool alertsEnabled,
    String? phoneNumber,
  }) {
    return {
      'whatsapp': {
        'enabled': whatsappEnabled,
        'phone_available': phoneNumber != null && phoneNumber.isNotEmpty,
      },
      'push_notifications': {
        'enabled': pushEnabled,
      },
      'email': {
        'enabled': emailEnabled,
      },
      'alerts': {
        'enabled': alertsEnabled,
      },
      'primary_method': whatsappEnabled && phoneNumber != null && phoneNumber.isNotEmpty
          ? 'WhatsApp'
          : pushEnabled
              ? 'Push Notifications'
              : 'None',
    };
  }
}