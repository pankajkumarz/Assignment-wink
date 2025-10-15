# API Keys Setup Guide

This project uses external configuration files for API keys to keep sensitive information secure and out of version control.

## Quick Setup

### 1. Copy Configuration Templates
```bash
# Copy the API keys template
cp api_keys.example.dart api_keys.dart

# Copy Android API keys templates
cp local_pulse_citizen/android/app/src/main/res/values/api_keys.example.xml local_pulse_citizen/android/app/src/main/res/values/api_keys.xml
cp local_pulse_authority/android/app/src/main/res/values/api_keys.example.xml local_pulse_authority/android/app/src/main/res/values/api_keys.xml
```

### 2. Add Your API Keys

#### In `api_keys.dart`:
```dart
class ApiKeys {
  static const String googleMapsApiKey = 'AIzaSyC...'; // Your actual Google Maps API key
  static const String firebaseApiKey = 'AIzaSyB...';   // Your Firebase API key
  // ... other keys
}
```

#### In Android `api_keys.xml` files:
```xml
<string name="google_maps_api_key">AIzaSyC...</string>
```

### 3. Required API Keys

| Service | Required | Purpose |
|---------|----------|---------|
| Google Maps API | ✅ Yes | Map display, geocoding, location services |
| Firebase | ✅ Yes | Authentication, database, storage |
| WhatsApp Business API | ❌ Optional | WhatsApp notifications |

### 4. Google Maps API Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Enable these APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Geocoding API
   - Places API
3. Create API key and add restrictions for your app packages

### 5. Firebase Setup

1. Create Firebase project
2. Add Android/iOS apps with package names:
   - `com.localpulse.citizen`
   - `com.localpulse.authority`
3. Download configuration files (handled by Firebase CLI)

## Security Notes

- ✅ `api_keys.dart` is in `.gitignore` - won't be committed
- ✅ `api_keys.xml` files are in `.gitignore` - won't be committed  
- ✅ Template files (`.example`) are safe to commit
- ✅ No hardcoded API keys in source code

## For New Developers

1. Clone the repository
2. Follow the "Quick Setup" steps above
3. Get API keys from team lead or create your own for development
4. Never commit the actual `api_keys.dart` or `api_keys.xml` files

## Production Deployment

For production builds, use environment variables or secure CI/CD secrets to inject API keys during build process.