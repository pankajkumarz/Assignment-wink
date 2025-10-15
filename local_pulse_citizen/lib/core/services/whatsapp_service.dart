import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class WhatsAppService {
  static WhatsAppService? _instance;
  static WhatsAppService get instance => _instance ??= WhatsAppService._();
  
  WhatsAppService._();

  /// Share issue report via WhatsApp
  Future<bool> shareIssueReport({
    required String issueId,
    required String title,
    required String description,
    required String status,
    String? trackingUrl,
  }) async {
    try {
      final message = _buildIssueMessage(
        issueId: issueId,
        title: title,
        description: description,
        status: status,
        trackingUrl: trackingUrl,
      );
      return await _sendWhatsAppMessage(message);
    } catch (e) {
      if (kDebugMode) {
        print('Error sharing issue via WhatsApp: $e');
      }
      return false;
    }
  }

  /// Share issue status update via WhatsApp
  Future<bool> shareStatusUpdate({
    required String issueId,
    required String title,
    required String oldStatus,
    required String newStatus,
    String? comment,
    String? trackingUrl,
  }) async {
    try {
      final message = _buildStatusUpdateMessage(
        issueId: issueId,
        title: title,
        oldStatus: oldStatus,
        newStatus: newStatus,
        comment: comment,
        trackingUrl: trackingUrl,
      );
      return await _sendWhatsAppMessage(message);
    } catch (e) {
      if (kDebugMode) {
        print('Error sharing status update via WhatsApp: $e');
      }
      return false;
    }
  }

  /// Send WhatsApp message to specific phone number (for notifications)
  Future<bool> sendNotificationMessage({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // Clean phone number (remove spaces, dashes, etc.)
      final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      final whatsappUrl = 'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}';
      final uri = Uri.parse(whatsappUrl);
      
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (kDebugMode) {
          print('Could not launch WhatsApp URL: $whatsappUrl');
        }
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error sending WhatsApp notification: $e');
      }
      return false;
    }
  }

  /// Share app invitation via WhatsApp
  Future<bool> shareAppInvitation() async {
    try {
      const message = '''
🏛️ *Local Pulse* - Civic Engagement App

Join me in making our community better! 

📱 Report civic issues instantly
📍 Track your reports in real-time  
🗺️ View community issues on map
🔔 Get notifications on resolution

Download Local Pulse and help improve our city!

#CivicEngagement #LocalPulse #CommunityFirst
      ''';
      return await _sendWhatsAppMessage(message);
    } catch (e) {
      if (kDebugMode) {
        print('Error sharing app invitation: $e');
      }
      return false;
    }
  }

  /// Check if WhatsApp is installed
  Future<bool> isWhatsAppInstalled() async {
    try {
      const whatsappUrl = 'https://wa.me/';
      final uri = Uri.parse(whatsappUrl);
      return await canLaunchUrl(uri);
    } catch (e) {
      if (kDebugMode) {
        print('Error checking WhatsApp installation: $e');
      }
      return false;
    }
  }

  /// Fallback to share via other apps if WhatsApp is not available
  Future<bool> shareViaOtherApps(String message) async {
    try {
      await Share.share(message);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error sharing via other apps: $e');
      }
      return false;
    }
  }

  /// Private method to send WhatsApp message
  Future<bool> _sendWhatsAppMessage(String message) async {
    try {
      // First try to check if WhatsApp is available
      if (await isWhatsAppInstalled()) {
        final whatsappUrl = 'https://wa.me/?text=${Uri.encodeComponent(message)}';
        final uri = Uri.parse(whatsappUrl);
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback to sharing via other apps
        return await shareViaOtherApps(message);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in _sendWhatsAppMessage: $e');
      }
      return false;
    }
  }

  /// Build issue report message
  String _buildIssueMessage({
    required String issueId,
    required String title,
    required String description,
    required String status,
    String? trackingUrl,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('🏛️ *Local Pulse - Issue Report*');
    buffer.writeln('');
    buffer.writeln('📋 *Issue ID:* #${issueId.substring(0, 8)}');
    buffer.writeln('📝 *Title:* $title');
    buffer.writeln('📄 *Description:* $description');
    buffer.writeln('📊 *Status:* ${_getStatusEmoji(status)} $status');
    buffer.writeln('📅 *Reported:* ${DateTime.now().toString().split(' ')[0]}');
    
    if (trackingUrl != null) {
      buffer.writeln('');
      buffer.writeln('🔗 *Track Progress:* $trackingUrl');
    }
    
    buffer.writeln('');
    buffer.writeln('Thank you for helping improve our community! 🙏');
    buffer.writeln('');
    buffer.writeln('#LocalPulse #CivicEngagement');
    
    return buffer.toString();
  }

  /// Build status update message
  String _buildStatusUpdateMessage({
    required String issueId,
    required String title,
    required String oldStatus,
    required String newStatus,
    String? comment,
    String? trackingUrl,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('🔔 *Local Pulse - Status Update*');
    buffer.writeln('');
    buffer.writeln('📋 *Issue ID:* #${issueId.substring(0, 8)}');
    buffer.writeln('📝 *Title:* $title');
    buffer.writeln('');
    buffer.writeln('📊 *Status Changed:*');
    buffer.writeln('   From: ${_getStatusEmoji(oldStatus)} $oldStatus');
    buffer.writeln('   To: ${_getStatusEmoji(newStatus)} $newStatus');
    
    if (comment != null && comment.isNotEmpty) {
      buffer.writeln('');
      buffer.writeln('💬 *Authority Comment:*');
      buffer.writeln(comment);
    }
    
    buffer.writeln('');
    buffer.writeln('📅 *Updated:* ${DateTime.now().toString().split(' ')[0]}');
    
    if (trackingUrl != null) {
      buffer.writeln('');
      buffer.writeln('🔗 *Track Progress:* $trackingUrl');
    }
    
    buffer.writeln('');
    buffer.writeln('Thank you for your patience! 🙏');
    buffer.writeln('');
    buffer.writeln('#LocalPulse #CivicEngagement');
    
    return buffer.toString();
  }

  /// Get emoji for status
  String _getStatusEmoji(String status) {
    switch (status.toLowerCase()) {
      case 'submitted':
        return '📝';
      case 'acknowledged':
        return '👀';
      case 'in_progress':
        return '🔄';
      case 'resolved':
        return '✅';
      case 'closed':
        return '🔒';
      case 'rejected':
        return '❌';
      default:
        return '📊';
    }
  }

  /// Build emergency alert message
  String buildEmergencyAlertMessage({
    required String alertTitle,
    required String alertMessage,
    required String location,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('🚨 *EMERGENCY ALERT - Local Pulse*');
    buffer.writeln('');
    buffer.writeln('⚠️ *Alert:* $alertTitle');
    buffer.writeln('📍 *Location:* $location');
    buffer.writeln('');
    buffer.writeln('📄 *Details:*');
    buffer.writeln(alertMessage);
    buffer.writeln('');
    buffer.writeln('📅 *Time:* ${DateTime.now().toString().split('.')[0]}');
    buffer.writeln('');
    buffer.writeln('Please stay safe and follow local authority instructions.');
    buffer.writeln('');
    buffer.writeln('#LocalPulse #EmergencyAlert #SafetyFirst');
    
    return buffer.toString();
  }

  /// Build civic news message
  String buildCivicNewsMessage({
    required String newsTitle,
    required String newsContent,
    required String category,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('📰 *Local Pulse - Civic News*');
    buffer.writeln('');
    buffer.writeln('🏛️ *Category:* $category');
    buffer.writeln('📝 *Title:* $newsTitle');
    buffer.writeln('');
    buffer.writeln('📄 *Details:*');
    buffer.writeln(newsContent);
    buffer.writeln('');
    buffer.writeln('📅 *Published:* ${DateTime.now().toString().split(' ')[0]}');
    buffer.writeln('');
    buffer.writeln('Stay informed about your community! 📱');
    buffer.writeln('');
    buffer.writeln('#LocalPulse #CivicNews #CommunityUpdate');
    
    return buffer.toString();
  }
}