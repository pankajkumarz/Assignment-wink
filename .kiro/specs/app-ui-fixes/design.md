# Design Document

## Overview

This design addresses the comprehensive UI/UX fixes and enhancements for the Local Pulse citizen app. The solution focuses on fixing layout issues, implementing proper navigation, adding missing functionality, and creating a robust alert system. The design emphasizes user experience improvements while maintaining the existing app architecture and adding new features seamlessly.

## Architecture

### UI Layout Architecture
- **SafeArea Implementation**: Wrap all pages with SafeArea widgets to handle system UI overlays
- **Responsive Layout System**: Use MediaQuery and LayoutBuilder for dynamic sizing
- **Consistent Padding Strategy**: Implement standardized padding constants for consistent spacing
- **Overflow Prevention**: Use Flexible, Expanded, and SingleChildScrollView widgets strategically

### Navigation Architecture
- **Centralized Route Management**: Update all navigation calls to use proper page constructors
- **Navigation State Management**: Ensure consistent navigation patterns across the app
- **Deep Linking Support**: Maintain proper route structure for future deep linking

### Data Persistence Architecture
- **Profile Data Layer**: Implement UserPreferences service using SharedPreferences and Firestore
- **Notification Settings**: Create NotificationPreferences service for toggle state management
- **Alert System**: Design AlertService with local caching and real-time updates

## Components and Interfaces

### 1. Layout Components

#### SafeAreaWrapper
```dart
class SafeAreaWrapper extends StatelessWidget {
  final Widget child;
  final EdgeInsets? additionalPadding;
  
  // Provides consistent safe area handling across all pages
}
```

#### ResponsiveContainer
```dart
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsets padding;
  
  // Handles responsive layout with consistent padding
}
```

### 2. Logo and Branding Components

#### AppLogo
```dart
class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  
  // Centralized logo component using assets/images/logo.png
}
```

#### AppIcon Configuration
- Update `android/app/src/main/res/` with proper icon sizes
- Update `ios/Runner/Assets.xcassets/AppIcon.appiconset/` with logo variants
- Configure `flutter_launcher_icons` package for automated icon generation

### 3. Navigation Components

#### NavigationService
```dart
class NavigationService {
  static void navigateToReportIssue(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => const ReportIssuePage(),
    ));
  }
  
  // Centralized navigation methods for consistency
}
```

### 4. Localization Components

#### LocalizationManager
```dart
class LocalizationManager {
  static const supportedLocales = [
    Locale('en', ''), // English
    Locale('es', ''), // Spanish  
    Locale('fr', ''), // French
  ];
  
  // Manages language switching and locale detection
}
```

#### Localized Text Keys
- Update ARB files with comprehensive text coverage
- Implement context-aware translations
- Add pluralization support for dynamic content

### 5. Profile Management Components

#### UserProfileService
```dart
class UserProfileService {
  Future<UserProfile> loadProfile();
  Future<void> saveProfile(UserProfile profile);
  Future<void> updateProfileField(String field, dynamic value);
  
  // Handles profile data persistence with Firestore sync
}
```

#### NotificationPreferencesService
```dart
class NotificationPreferencesService {
  Future<NotificationSettings> loadSettings();
  Future<void> saveSettings(NotificationSettings settings);
  Future<void> toggleSetting(String settingKey, bool value);
  
  // Manages notification preferences with immediate persistence
}
```

### 6. Alert System Components

#### AlertService
```dart
class AlertService {
  Stream<List<CommunityAlert>> getAlertsStream();
  Future<void> markAlertAsRead(String alertId);
  Future<void> subscribeToAlertTypes(List<AlertType> types);
  
  // Manages community alerts with real-time updates
}
```

#### CommunityAlert Model
```dart
class CommunityAlert {
  final String id;
  final String title;
  final String description;
  final AlertType type;
  final AlertPriority priority;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  
  // Comprehensive alert data structure
}
```

#### AlertWidget
```dart
class AlertWidget extends StatelessWidget {
  final CommunityAlert alert;
  final VoidCallback? onTap;
  
  // Reusable alert display component with priority styling
}
```

## Data Models

### Enhanced User Profile Model
```dart
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? city;
  final String? profileImageUrl;
  final DateTime lastUpdated;
  
  // Extended profile with persistence tracking
}
```

### Notification Settings Model
```dart
class NotificationSettings {
  final bool pushNotifications;
  final bool emailNotifications;
  final bool issueUpdates;
  final bool communityAlerts;
  final bool maintenanceNotifications;
  final bool soundEnabled;
  final bool vibrationEnabled;
  
  // Comprehensive notification preferences
}
```

### Alert System Models
```dart
enum AlertType {
  emergency,
  maintenance,
  weather,
  traffic,
  community,
  safety
}

enum AlertPriority {
  critical,
  high,
  medium,
  low
}

class AlertNotification {
  final String alertId;
  final String title;
  final String body;
  final AlertPriority priority;
  final Map<String, dynamic>? data;
  
  // Push notification structure for alerts
}
```

## Error Handling

### Layout Error Prevention
- Implement overflow detection and automatic adjustment
- Use try-catch blocks around layout-sensitive operations
- Provide fallback layouts for edge cases
- Log layout issues for debugging

### Navigation Error Handling
- Validate route parameters before navigation
- Implement navigation guards for authentication
- Handle back navigation edge cases
- Provide error pages for invalid routes

### Data Persistence Error Handling
- Implement retry mechanisms for failed saves
- Provide offline data caching
- Handle network connectivity issues
- Show user-friendly error messages

### Alert System Error Handling
- Implement graceful degradation for alert failures
- Cache alerts locally for offline viewing
- Handle push notification permission issues
- Provide manual refresh options

## Testing Strategy

### Unit Testing
- Test layout calculation functions
- Test navigation service methods
- Test data persistence services
- Test alert processing logic
- Test localization key resolution

### Widget Testing
- Test responsive layout behavior
- Test navigation flows
- Test form validation and submission
- Test alert display components
- Test preference toggle functionality

### Integration Testing
- Test end-to-end user flows
- Test data synchronization
- Test push notification handling
- Test multi-language switching
- Test profile save/load cycles

### UI Testing
- Test layout on different screen sizes
- Test overflow scenarios
- Test navigation bar interactions
- Test floating action button positioning
- Test alert notification display

## Implementation Phases

### Phase 1: Layout and Navigation Fixes
1. Implement SafeArea wrappers
2. Fix floating action button positioning
3. Update navigation calls to use ReportIssuePage
4. Fix grid aspect ratios and padding
5. Resolve overflow issues

### Phase 2: Logo and Branding
1. Configure app icons using logo.jpg
2. Update splash screen with proper logo
3. Implement AppLogo component
4. Update app bar branding

### Phase 3: Localization Implementation
1. Complete ARB file translations
2. Update all hardcoded strings
3. Implement language switching
4. Test multi-language support

### Phase 4: Profile and Preferences
1. Implement UserProfileService
2. Add profile data persistence
3. Fix notification preference toggles
4. Implement settings synchronization

### Phase 5: Alert System
1. Create alert data models
2. Implement AlertService
3. Design alert UI components
4. Add push notification support
5. Implement alert management features

### Phase 6: Testing and Polish
1. Comprehensive testing across all features
2. Performance optimization
3. Accessibility improvements
4. Final UI polish and refinements