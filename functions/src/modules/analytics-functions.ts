import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

const db = admin.firestore();

/**
 * Scheduled function to generate daily analytics
 */
export const generateDailyAnalytics = functions.pubsub
  .schedule('every day 02:00')
  .timeZone('UTC')
  .onRun(async (context) => {
    try {
      const today = new Date();
      const yesterday = new Date(today.getTime() - 24 * 60 * 60 * 1000);
      
      // Get all cities
      const citiesSnapshot = await db.collection('users')
        .where('isActive', '==', true)
        .get();
      
      const cities = new Set<string>();
      citiesSnapshot.docs.forEach(doc => {
        const userData = doc.data();
        if (userData.city) {
          cities.add(userData.city);
        }
      });

      // Generate analytics for each city
      for (const city of cities) {
        await generateCityAnalytics(city, yesterday);
      }

      console.log(`Daily analytics generated for ${cities.size} cities`);
      return null;
    } catch (error) {
      console.error('Error generating daily analytics:', error);
      return null;
    }
  });

/**
 * HTTP function to get dashboard analytics
 */
export const getDashboardAnalytics = functions.https.onCall(async (data, context) => {
  try {
    // Check if user is authenticated and has authority/admin role
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const userClaims = context.auth.token;
    if (userClaims.role !== 'authority' && userClaims.role !== 'admin') {
      throw new functions.https.HttpsError('permission-denied', 'Only authorities can access analytics');
    }

    const { city, timeRange } = data;
    
    if (!city) {
      throw new functions.https.HttpsError('invalid-argument', 'City is required');
    }

    const endDate = new Date();
    let startDate: Date;

    switch (timeRange) {
      case 'week':
        startDate = new Date(endDate.getTime() - 7 * 24 * 60 * 60 * 1000);
        break;
      case 'month':
        startDate = new Date(endDate.getTime() - 30 * 24 * 60 * 60 * 1000);
        break;
      case 'year':
        startDate = new Date(endDate.getTime() - 365 * 24 * 60 * 60 * 1000);
        break;
      default:
        startDate = new Date(endDate.getTime() - 30 * 24 * 60 * 60 * 1000);
    }

    // Get issues analytics
    const issuesQuery = await db
      .collection('issues')
      .where('city', '==', city)
      .where('createdAt', '>=', startDate)
      .where('createdAt', '<=', endDate)
      .get();

    const issues = issuesQuery.docs.map(doc => doc.data());

    // Calculate metrics
    const totalIssues = issues.length;
    const resolvedIssues = issues.filter(issue => issue.status === 'resolved').length;
    const pendingIssues = issues.filter(issue => 
      ['submitted', 'acknowledged', 'in_progress'].includes(issue.status)
    ).length;

    // Category breakdown
    const categoryBreakdown: { [key: string]: number } = {};
    issues.forEach(issue => {
      categoryBreakdown[issue.category] = (categoryBreakdown[issue.category] || 0) + 1;
    });

    // Priority breakdown
    const priorityBreakdown: { [key: string]: number } = {};
    issues.forEach(issue => {
      priorityBreakdown[issue.priority] = (priorityBreakdown[issue.priority] || 0) + 1;
    });

    // Calculate average resolution time
    const resolvedIssuesWithTime = issues.filter(issue => 
      issue.status === 'resolved' && issue.resolvedAt && issue.createdAt
    );

    let averageResolutionTime = 0;
    if (resolvedIssuesWithTime.length > 0) {
      const totalResolutionTime = resolvedIssuesWithTime.reduce((sum, issue) => {
        const resolutionTime = issue.resolvedAt.toDate().getTime() - issue.createdAt.toDate().getTime();
        return sum + resolutionTime;
      }, 0);
      averageResolutionTime = totalResolutionTime / resolvedIssuesWithTime.length;
    }

    // Get user engagement metrics
    const usersQuery = await db
      .collection('users')
      .where('city', '==', city)
      .where('isActive', '==', true)
      .get();

    const totalUsers = usersQuery.size;
    const activeUsers = usersQuery.docs.filter(doc => {
      const userData = doc.data();
      const lastActive = userData.lastActiveAt?.toDate();
      return lastActive && lastActive >= startDate;
    }).length;

    // Get feedback metrics
    const feedbackQuery = await db
      .collection('issues')
      .where('city', '==', city)
      .where('feedback', '!=', null)
      .where('createdAt', '>=', startDate)
      .get();

    const feedbackData = feedbackQuery.docs.map(doc => doc.data().feedback);
    const averageRating = feedbackData.length > 0 
      ? feedbackData.reduce((sum, feedback) => sum + feedback.rating, 0) / feedbackData.length
      : 0;

    return {
      summary: {
        totalIssues,
        resolvedIssues,
        pendingIssues,
        resolutionRate: totalIssues > 0 ? (resolvedIssues / totalIssues) * 100 : 0,
        averageResolutionTime: Math.round(averageResolutionTime / (1000 * 60 * 60)), // in hours
        totalUsers,
        activeUsers,
        averageRating: Math.round(averageRating * 10) / 10,
      },
      breakdowns: {
        category: categoryBreakdown,
        priority: priorityBreakdown,
      },
      timeRange: {
        start: startDate.toISOString(),
        end: endDate.toISOString(),
      },
    };
  } catch (error) {
    console.error('Error getting dashboard analytics:', error);
    throw error;
  }
});

/**
 * HTTP function to get performance metrics
 */
export const getPerformanceMetrics = functions.https.onCall(async (data, context) => {
  try {
    // Check if user is authenticated and has admin role
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const userClaims = context.auth.token;
    if (userClaims.role !== 'admin') {
      throw new functions.https.HttpsError('permission-denied', 'Only admins can access performance metrics');
    }

    const { city, departmentId } = data;

    // Get department performance
    const issuesQuery = db.collection('issues').where('city', '==', city);
    
    if (departmentId) {
      issuesQuery.where('assignedDepartment', '==', departmentId);
    }

    const issuesSnapshot = await issuesQuery.get();
    const issues = issuesSnapshot.docs.map(doc => doc.data());

    // Calculate department metrics
    const departmentMetrics: { [key: string]: {
      totalIssues: number;
      resolvedIssues: number;
      averageResolutionTime: number;
      resolutionTimes: number[];
    } } = {};

    issues.forEach(issue => {
      const dept = issue.assignedDepartment || 'unassigned';
      
      if (!departmentMetrics[dept]) {
        departmentMetrics[dept] = {
          totalIssues: 0,
          resolvedIssues: 0,
          averageResolutionTime: 0,
          resolutionTimes: [],
        };
      }

      departmentMetrics[dept].totalIssues++;

      if (issue.status === 'resolved') {
        departmentMetrics[dept].resolvedIssues++;
        
        if (issue.resolvedAt && issue.createdAt) {
          const resolutionTime = issue.resolvedAt.toDate().getTime() - issue.createdAt.toDate().getTime();
          departmentMetrics[dept].resolutionTimes.push(resolutionTime);
        }
      }
    });

    // Calculate average resolution times
    Object.keys(departmentMetrics).forEach(dept => {
      const times = departmentMetrics[dept].resolutionTimes;
      if (times.length > 0) {
        departmentMetrics[dept].averageResolutionTime = 
          times.reduce((sum, time) => sum + time, 0) / times.length;
      }
      delete departmentMetrics[dept].resolutionTimes; // Remove raw data
    });

    return {
      city,
      departmentMetrics,
      generatedAt: new Date().toISOString(),
    };
  } catch (error) {
    console.error('Error getting performance metrics:', error);
    throw error;
  }
});

/**
 * Helper function to generate city analytics
 */
async function generateCityAnalytics(city: string, date: Date) {
  try {
    const startOfDay = new Date(date.getFullYear(), date.getMonth(), date.getDate());
    const endOfDay = new Date(startOfDay.getTime() + 24 * 60 * 60 * 1000);

    // Get issues for the day
    const issuesQuery = await db
      .collection('issues')
      .where('city', '==', city)
      .where('createdAt', '>=', startOfDay)
      .where('createdAt', '<', endOfDay)
      .get();

    const issues = issuesQuery.docs.map(doc => doc.data());

    // Calculate daily metrics
    const analytics = {
      city,
      date: startOfDay,
      totalIssues: issues.length,
      resolvedIssues: issues.filter(issue => issue.status === 'resolved').length,
      emergencyIssues: issues.filter(issue => issue.priority === 'emergency').length,
      categoryBreakdown: {} as { [key: string]: number },
      priorityBreakdown: {} as { [key: string]: number },
      generatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    // Calculate breakdowns
    issues.forEach(issue => {
      analytics.categoryBreakdown[issue.category] = 
        (analytics.categoryBreakdown[issue.category] || 0) + 1;
      analytics.priorityBreakdown[issue.priority] = 
        (analytics.priorityBreakdown[issue.priority] || 0) + 1;
    });

    // Save analytics
    const analyticsId = `${city}_${startOfDay.toISOString().split('T')[0]}`;
    await db.collection('daily_analytics').doc(analyticsId).set(analytics);

    console.log(`Generated analytics for ${city} on ${startOfDay.toDateString()}`);
  } catch (error) {
    console.error(`Error generating analytics for ${city}:`, error);
  }
}

/**
 * HTTP function to export analytics data
 */
export const exportAnalyticsData = functions.https.onCall(async (data, context) => {
  try {
    // Check if user is authenticated and has admin role
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
    }

    const userClaims = context.auth.token;
    if (userClaims.role !== 'admin') {
      throw new functions.https.HttpsError('permission-denied', 'Only admins can export analytics data');
    }

    const { city, startDate, endDate, format } = data;

    if (!city || !startDate || !endDate) {
      throw new functions.https.HttpsError('invalid-argument', 'City, startDate, and endDate are required');
    }

    // Get analytics data for the date range
    const analyticsQuery = await db
      .collection('daily_analytics')
      .where('city', '==', city)
      .where('date', '>=', new Date(startDate))
      .where('date', '<=', new Date(endDate))
      .orderBy('date')
      .get();

    const analyticsData = analyticsQuery.docs.map(doc => doc.data());

    // Format data based on requested format
    if (format === 'csv') {
      // Convert to CSV format
      const csvData = convertToCSV(analyticsData);
      return { data: csvData, format: 'csv' };
    } else {
      // Return as JSON
      return { data: analyticsData, format: 'json' };
    }
  } catch (error) {
    console.error('Error exporting analytics data:', error);
    throw error;
  }
});

/**
 * Helper function to convert data to CSV
 */
function convertToCSV(data: Record<string, unknown>[]): string {
  if (data.length === 0) return '';

  const headers = Object.keys(data[0]).filter(key => typeof data[0][key] !== 'object');
  const csvRows = [headers.join(',')];

  data.forEach(row => {
    const values = headers.map(header => {
      const value = row[header];
      return typeof value === 'string' ? `"${value}"` : value;
    });
    csvRows.push(values.join(','));
  });

  return csvRows.join('\n');
}

// Export all analytics functions
export const analyticsFunctions = {
  generateDailyAnalytics,
  getDashboardAnalytics,
  getPerformanceMetrics,
  exportAnalyticsData,
};