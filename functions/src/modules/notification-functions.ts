import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * HTTP function to send bulk notifications
 */
export const sendBulkNotification = functions.https.onCall(async (data, context) => {
  try {
    // Check if user is authenticated and has admin role
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const userClaims = context.auth.token;
    if (userClaims.role !== 'admin') {
      throw new functions.https.HttpsError('permission-denied', 'Only admins can send bulk notifications');
    }

    const { title, body, targetAudience, city, data: notificationData } = data;

    if (!title || !body) {
      throw new functions.https.HttpsError('invalid-argument', 'Title and body are required');
    }

    // Build query based on target audience
    let query = db.collection('users').where('isActive', '==', true);

    if (targetAudience === 'citizens') {
      query = query.where('role', '==', 'citizen');
    } else if (targetAudience === 'authorities') {
      query = query.where('role', '==', 'authority');
    }

    if (city) {
      query = query.where('city', '==', city);
    }

    const usersSnapshot = await query.get();
    const tokens: string[] = [];

    usersSnapshot.docs.forEach((doc) => {
      const userData = doc.data();
      if (userData.fcmToken && userData.preferences?.notifications?.pushEnabled) {
        tokens.push(userData.fcmToken);
      }
    });

    if (tokens.length === 0) {
      return { success: true, message: 'No users to notify', sentCount: 0 };
    }

    // Send notifications in batches of 500 (FCM limit)
    const batchSize = 500;
    let sentCount = 0;

    for (let i = 0; i < tokens.length; i += batchSize) {
      const batch = tokens.slice(i, i + batchSize);
      
      try {
        const response = await admin.messaging().sendMulticast({
          tokens: batch,
          notification: { title, body },
          data: notificationData || {},
        });

        sentCount += response.successCount;

        // Clean up invalid tokens
        if (response.failureCount > 0) {
          const invalidTokens: string[] = [];
          response.responses.forEach((resp, idx) => {
            if (!resp.success && resp.error?.code === 'messaging/registration-token-not-registered') {
              invalidTokens.push(batch[idx]);
            }
          });

          // Remove invalid tokens from user documents
          await cleanupInvalidTokens(invalidTokens);
        }
      } catch (error) {
        console.error('Error sending notification batch:', error);
      }
    }

    console.log(`Bulk notification sent to ${sentCount} users`);

    return {
      success: true,
      message: 'Bulk notification sent successfully',
      sentCount: sentCount,
      totalTargeted: tokens.length,
    };
  } catch (error) {
    console.error('Error sending bulk notification:', error);
    throw error;
  }
});

/**
 * HTTP function to send emergency alert
 */
export const sendEmergencyAlert = functions.https.onCall(async (data, context) => {
  try {
    // Check if user is authenticated and has authority/admin role
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const userClaims = context.auth.token;
    if (userClaims.role !== 'authority' && userClaims.role !== 'admin') {
      throw new functions.https.HttpsError('permission-denied', 'Only authorities can send emergency alerts');
    }

    const { title, message, city, radiusKm, location, priority } = data;

    if (!title || !message || !city) {
      throw new functions.https.HttpsError('invalid-argument', 'Title, message, and city are required');
    }

    // Create alert document
    const alertData = {
      title: title,
      message: message,
      type: 'emergency',
      priority: priority || 'high',
      city: city,
      location: location || null,
      radiusKm: radiusKm || 10,
      isActive: true,
      createdBy: context.auth.uid,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000), // 24 hours
    };

    const alertRef = await db.collection('alerts').add(alertData);

    // Get users in the affected area
    let usersQuery = db.collection('users')
      .where('city', '==', city)
      .where('isActive', '==', true)
      .where('preferences.notifications.alerts', '==', true);

    const usersSnapshot = await usersQuery.get();
    const tokens: string[] = [];

    usersSnapshot.docs.forEach((doc) => {
      const userData = doc.data();
      
      // Check if user is within radius if location is specified
      if (location && userData.lastKnownLocation) {
        const distance = calculateDistance(
          location.latitude,
          location.longitude,
          userData.lastKnownLocation.latitude,
          userData.lastKnownLocation.longitude
        );
        
        if (distance > radiusKm) {
          return; // Skip users outside radius
        }
      }

      if (userData.fcmToken) {
        tokens.push(userData.fcmToken);
      }
    });

    // Send high-priority emergency notifications
    if (tokens.length > 0) {
      const batchSize = 500;
      let sentCount = 0;

      for (let i = 0; i < tokens.length; i += batchSize) {
        const batch = tokens.slice(i, i + batchSize);
        
        try {
          const response = await admin.messaging().sendMulticast({
            tokens: batch,
            notification: {
              title: `🚨 EMERGENCY: ${title}`,
              body: message,
            },
            data: {
              type: 'emergency_alert',
              alertId: alertRef.id,
              priority: 'high',
            },
            android: {
              priority: 'high',
              notification: {
                priority: 'high',
                defaultSound: true,
                defaultVibrateTimings: true,
              },
            },
            apns: {
              payload: {
                aps: {
                  alert: {
                    title: `🚨 EMERGENCY: ${title}`,
                    body: message,
                  },
                  sound: 'default',
                  badge: 1,
                },
              },
            },
          });

          sentCount += response.successCount;
        } catch (error) {
          console.error('Error sending emergency alert batch:', error);
        }
      }

      console.log(`Emergency alert sent to ${sentCount} users in ${city}`);
    }

    return {
      success: true,
      message: 'Emergency alert sent successfully',
      alertId: alertRef.id,
      sentCount: tokens.length,
    };
  } catch (error) {
    console.error('Error sending emergency alert:', error);
    throw error;
  }
});

/**
 * Scheduled function to clean up expired notifications
 */
export const cleanupExpiredNotifications = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    try {
      const now = new Date();
      
      // Clean up expired alerts
      const expiredAlertsQuery = await db
        .collection('alerts')
        .where('expiresAt', '<', now)
        .where('isActive', '==', true)
        .get();

      const batch = db.batch();
      expiredAlertsQuery.docs.forEach((doc) => {
        batch.update(doc.ref, { isActive: false });
      });

      await batch.commit();

      console.log(`Deactivated ${expiredAlertsQuery.size} expired alerts`);

      // Clean up old notification logs (older than 30 days)
      const oldLogsQuery = await db
        .collection('notification_logs')
        .where('createdAt', '<', new Date(Date.now() - 30 * 24 * 60 * 60 * 1000))
        .limit(500)
        .get();

      const deleteBatch = db.batch();
      oldLogsQuery.docs.forEach((doc) => {
        deleteBatch.delete(doc.ref);
      });

      await deleteBatch.commit();

      console.log(`Deleted ${oldLogsQuery.size} old notification logs`);

      return null;
    } catch (error) {
      console.error('Error cleaning up notifications:', error);
      return null;
    }
  });

/**
 * HTTP function to update FCM token
 */
export const updateFCMToken = functions.https.onCall(async (data, context) => {
  try {
    // Check if user is authenticated
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const { token } = data;
    const userId = context.auth.uid;

    if (!token) {
      throw new functions.https.HttpsError('invalid-argument', 'FCM token is required');
    }

    // Update user's FCM token
    await db.collection('users').doc(userId).update({
      fcmToken: token,
      tokenUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log('FCM token updated for user:', userId);

    return { success: true, message: 'FCM token updated successfully' };
  } catch (error) {
    console.error('Error updating FCM token:', error);
    throw error;
  }
});

/**
 * Helper function to clean up invalid FCM tokens
 */
async function cleanupInvalidTokens(invalidTokens: string[]) {
  try {
    const batch = db.batch();
    
    for (const token of invalidTokens) {
      const usersQuery = await db
        .collection('users')
        .where('fcmToken', '==', token)
        .limit(1)
        .get();

      usersQuery.docs.forEach((doc) => {
        batch.update(doc.ref, {
          fcmToken: admin.firestore.FieldValue.delete(),
        });
      });
    }

    await batch.commit();
    console.log(`Cleaned up ${invalidTokens.length} invalid FCM tokens`);
  } catch (error) {
    console.error('Error cleaning up invalid tokens:', error);
  }
}

/**
 * Helper function to calculate distance between two points
 */
function calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 6371; // Earth's radius in kilometers
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

// Export all notification functions
export const notificationFunctions = {
  sendBulkNotification,
  sendEmergencyAlert,
  cleanupExpiredNotifications,
  updateFCMToken,
};