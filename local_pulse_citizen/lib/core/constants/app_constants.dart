class AppConstants {
  // App Information
  static const String appName = 'Local Pulse';
  static const String appVersion = '1.0.0';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String issuesCollection = 'issues';
  static const String alertsCollection = 'alerts';
  static const String categoriesCollection = 'categories';
  static const String notificationsCollection = 'notifications';
  
  // Issue Categories
  static const String dailyLifeCategory = 'daily_life';
  static const String emergencyCategory = 'emergency';
  static const String generalCategory = 'general';
  
  // Issue Status
  static const String statusSubmitted = 'submitted';
  static const String statusAcknowledged = 'acknowledged';
  static const String statusInProgress = 'in_progress';
  static const String statusResolved = 'resolved';
  static const String statusClosed = 'closed';
  static const String statusRejected = 'rejected';
  
  // User Roles
  static const String roleCitizen = 'citizen';
  static const String roleAuthority = 'authority';
  static const String roleAdmin = 'admin';
  
  // Themes
  static const String themeLight = 'light';
  static const String themeDark = 'dark';
  static const String themeSystem = 'system';
  
  // Languages
  static const String languageEnglish = 'en';
  static const String languageHindi = 'hi';
  
  // Map Settings
  static const double defaultLatitude = 28.6139; // New Delhi
  static const double defaultLongitude = 77.2090;
  static const double defaultZoom = 12.0;
  
  // File Upload
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
  
  // Notification Settings
  static const int escalationDays = 7;
}