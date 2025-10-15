import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Initialize Firebase Admin
admin.initializeApp();

// Import function modules
import { userFunctions } from './modules/user-functions';
import { issueFunctions } from './modules/issue-functions';
import { notificationFunctions } from './modules/notification-functions';
import { analyticsFunctions } from './modules/analytics-functions';

// Export all functions
export const user = userFunctions;
export const issue = issueFunctions;
export const notification = notificationFunctions;
export const analytics = analyticsFunctions;

// Health check function
export const healthCheck = functions.https.onRequest((request, response) => {
  response.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: '1.0.0'
  });
});