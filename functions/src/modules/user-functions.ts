import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();
const auth = admin.auth();

/**
 * Triggered when a new user is created
 * Sets up user profile and assigns custom claims
 */
export const onUserCreate = functions.auth.user().onCreate(async (user) => {
  try {
    console.log('New user created:', user.uid);

    // Create user profile document
    const userProfile = {
      uid: user.uid,
      email: user.email,
      displayName: user.displayName || '',
      photoURL: user.photoURL || '',
      role: 'citizen', // Default role
      isActive: true,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      preferences: {
        language: 'en',
        theme: 'system',
        notifications: {
          pushEnabled: true,
          emailEnabled: true,
          whatsappEnabled: false,
          alerts: true,
        },
      },
      stats: {
        totalReports: 0,
        resolvedReports: 0,
        feedbackGiven: 0,
      },
    };

    // Save user profile to Firestore
    await db.collection('users').doc(user.uid).set(userProfile);

    // Set custom claims for role-based access
    await auth.setCustomUserClaims(user.uid, {
      role: 'citizen',
      isActive: true,
    });

    console.log('User profile created successfully for:', user.uid);
  } catch (error) {
    console.error('Error creating user profile:', error);
  }
});

/**
 * Triggered when a user is deleted
 * Cleans up user data and related documents
 */
export const onUserDelete = functions.auth.user().onDelete(async (user) => {
  try {
    console.log('User deleted:', user.uid);

    // Delete user profile
    await db.collection('users').doc(user.uid).delete();

    // Anonymize user's issues (don't delete for transparency)
    const issuesQuery = await db
      .collection('issues')
      .where('reporterId', '==', user.uid)
      .get();

    const batch = db.batch();
    issuesQuery.docs.forEach((doc) => {
      batch.update(doc.ref, {
        reporterId: 'deleted_user',
        reporterName: 'Deleted User',
        reporterEmail: 'deleted@example.com',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    await batch.commit();

    console.log('User data cleaned up successfully for:', user.uid);
  } catch (error) {
    console.error('Error cleaning up user data:', error);
  }
});

/**
 * HTTP function to update user role (admin only)
 */
export const updateUserRole = functions.https.onCall(async (data, context) => {
  try {
    // Check if user is authenticated
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    // Check if user has admin role
    const adminClaims = context.auth.token;
    if (adminClaims.role !== 'admin') {
      throw new functions.https.HttpsError('permission-denied', 'Only admins can update user roles');
    }

    const { userId, newRole } = data;

    if (!userId || !newRole) {
      throw new functions.https.HttpsError('invalid-argument', 'userId and newRole are required');
    }

    // Validate role
    const validRoles = ['citizen', 'authority', 'admin'];
    if (!validRoles.includes(newRole)) {
      throw new functions.https.HttpsError('invalid-argument', 'Invalid role specified');
    }

    // Update custom claims
    await auth.setCustomUserClaims(userId, {
      role: newRole,
      isActive: true,
    });

    // Update user profile in Firestore
    await db.collection('users').doc(userId).update({
      role: newRole,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log(`User role updated: ${userId} -> ${newRole}`);

    return { success: true, message: 'User role updated successfully' };
  } catch (error) {
    console.error('Error updating user role:', error);
    throw error;
  }
});

/**
 * HTTP function to get user statistics
 */
export const getUserStats = functions.https.onCall(async (data, context) => {
  try {
    // Check if user is authenticated
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const userId = context.auth.uid;

    // Get user profile
    const userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'User profile not found');
    }

    const userData = userDoc.data();

    // Calculate real-time statistics
    const issuesQuery = await db
      .collection('issues')
      .where('reporterId', '==', userId)
      .get();

    const totalReports = issuesQuery.size;
    const resolvedReports = issuesQuery.docs.filter(
      (doc) => doc.data().status === 'resolved'
    ).length;

    const feedbackQuery = await db
      .collection('issues')
      .where('reporterId', '==', userId)
      .where('feedback', '!=', null)
      .get();

    const feedbackGiven = feedbackQuery.size;

    // Update stats in user profile
    await db.collection('users').doc(userId).update({
      'stats.totalReports': totalReports,
      'stats.resolvedReports': resolvedReports,
      'stats.feedbackGiven': feedbackGiven,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return {
      totalReports,
      resolvedReports,
      feedbackGiven,
      resolutionRate: totalReports > 0 ? (resolvedReports / totalReports) * 100 : 0,
      city: userData?.city || '',
      joinDate: userData?.createdAt || null,
    };
  } catch (error) {
    console.error('Error getting user stats:', error);
    throw error;
  }
});

/**
 * HTTP function to update user preferences
 */
export const updateUserPreferences = functions.https.onCall(async (data, context) => {
  try {
    // Check if user is authenticated
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const userId = context.auth.uid;
    const { preferences } = data;

    if (!preferences) {
      throw new functions.https.HttpsError('invalid-argument', 'Preferences are required');
    }

    // Update user preferences
    await db.collection('users').doc(userId).update({
      preferences: preferences,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log('User preferences updated for:', userId);

    return { success: true, message: 'Preferences updated successfully' };
  } catch (error) {
    console.error('Error updating user preferences:', error);
    throw error;
  }
});

// Export all user functions
export const userFunctions = {
  onUserCreate,
  onUserDelete,
  updateUserRole,
  getUserStats,
  updateUserPreferences,
};