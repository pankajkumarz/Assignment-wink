# Design Document

## Overview

The post-submission feedback system will be implemented as a modal dialog that appears immediately after a successful issue report submission. The system will collect both quantitative (star ratings) and qualitative (text feedback) data to help improve the user experience and provide insights to administrators.

## Architecture

### Component Structure
```
FeedbackDialog (Modal)
├── FeedbackHeader (Title & Description)
├── StarRating (Interactive 1-5 star component)
├── FeedbackTextInput (Optional text field)
├── ActionButtons (Submit & Skip)
└── LoadingOverlay (During submission)
```

### Data Flow
1. Issue submission completes successfully
2. FeedbackService checks if feedback already provided for this submission
3. If not provided, FeedbackDialog is shown
4. User interacts with rating and/or text input
5. Feedback data is saved locally via FeedbackService
6. Dialog closes and user navigates to appropriate screen

## Components and Interfaces

### FeedbackDialog Widget
```dart
class FeedbackDialog extends StatefulWidget {
  final String issueId;
  final VoidCallback onComplete;
  final VoidCallback onSkip;
}
```

**Properties:**
- `issueId`: Links feedback to specific issue submission
- `onComplete`: Callback when feedback is submitted
- `onSkip`: Callback when user skips feedback

### StarRating Widget
```dart
class StarRating extends StatefulWidget {
  final int initialRating;
  final ValueChanged<int> onRatingChanged;
  final double size;
}
```

**Features:**
- Interactive tap-to-rate functionality
- Visual feedback with filled/unfilled stars
- Customizable star size and colors

### FeedbackService
```dart
class FeedbackService {
  Future<void> saveFeedback(FeedbackModel feedback);
  Future<bool> hasFeedbackForIssue(String issueId);
  Future<List<FeedbackModel>> getAllFeedback();
  Future<void> clearOldFeedback();
}
```

**Responsibilities:**
- Store feedback data locally using SharedPreferences/Hive
- Check if feedback already exists for an issue
- Provide analytics data retrieval
- Handle data cleanup for old feedback

## Data Models

### FeedbackModel
```dart
class FeedbackModel {
  final String id;
  final String issueId;
  final int rating; // 1-5 stars
  final String? textFeedback;
  final DateTime timestamp;
  final String? userId;
  
  // JSON serialization methods
  Map<String, dynamic> toJson();
  factory FeedbackModel.fromJson(Map<String, dynamic> json);
}
```

### Integration Points

#### Report Issue Page Integration
- Modify `_submitIssue()` method in `ReportIssuePage`
- Add feedback dialog trigger after successful submission
- Handle navigation flow post-feedback

#### Navigation Flow
```
Issue Submission Success
    ↓
Check if feedback already provided
    ↓
Show FeedbackDialog (if not provided)
    ↓
User provides feedback OR skips
    ↓
Navigate to Home/MyIssues page
```

## User Interface Design

### Dialog Layout
- **Header**: "How was your experience?" with subtitle
- **Star Rating**: Large, interactive 5-star rating component
- **Text Input**: Optional multiline text field with placeholder
- **Actions**: "Submit Feedback" (primary) and "Skip" (secondary) buttons

### Visual Design
- Modal dialog with rounded corners and shadow
- Primary color scheme matching app theme
- Clear visual hierarchy with appropriate spacing
- Responsive design for different screen sizes

### Animations
- Smooth dialog slide-in animation
- Star rating tap animations with scale effect
- Loading spinner during feedback submission
- Success checkmark animation on completion

## Error Handling

### Feedback Submission Errors
- Network connectivity issues: Store locally and retry later
- Storage errors: Show user-friendly error message
- Validation errors: Highlight required fields

### Graceful Degradation
- If feedback service fails, allow user to continue without blocking
- Provide fallback navigation if dialog fails to show
- Handle edge cases like app backgrounding during feedback

## Testing Strategy

### Unit Tests
- FeedbackService methods (save, retrieve, validation)
- FeedbackModel serialization/deserialization
- StarRating component interaction logic

### Widget Tests
- FeedbackDialog rendering and interaction
- StarRating tap behavior and visual updates
- Form validation and submission flow

### Integration Tests
- End-to-end feedback flow from issue submission
- Navigation flow after feedback completion
- Data persistence across app sessions

## Performance Considerations

### Optimization
- Lazy loading of feedback dialog components
- Efficient local storage with minimal data footprint
- Debounced text input to prevent excessive updates

### Memory Management
- Proper disposal of controllers and listeners
- Efficient image/icon caching for star ratings
- Cleanup of temporary feedback data

## Accessibility

### Screen Reader Support
- Semantic labels for star ratings
- Descriptive text for all interactive elements
- Proper focus management in dialog

### Keyboard Navigation
- Tab order through dialog elements
- Enter key submission support
- Escape key to dismiss dialog

### Visual Accessibility
- High contrast colors for star ratings
- Sufficient touch target sizes (44px minimum)
- Clear visual feedback for all interactions