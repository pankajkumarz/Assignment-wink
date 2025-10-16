# 🔥 Firebase Setup Guide

## Quick Setup (Recommended)

### 1. Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

### 2. Login to Firebase
```bash
firebase login
```

### 3. Auto-configure Firebase (from project root)
```bash
cd local_pulse_authority
flutterfire configure
```

This will:
- ✅ Automatically download `google-services.json`
- ✅ Generate correct `firebase_options.dart`
- ✅ Configure all platforms (Android, iOS, Web)

### 4. Select Your Options
When prompted:
- **Project**: Choose your Firebase project
- **Platforms**: Select Android (and iOS/Web if needed)
- **Package name**: Use `com.localpulse.authority.local_pulse_authority`

## Manual Setup (Alternative)

### File Locations:
```
📂 local_pulse_authority/
├── 📂 android/app/
│   └── 📄 google-services.json     ← Replace this file
├── 📂 lib/
│   └── 📄 firebase_options.dart    ← Update this file
```

### What to Replace:

**In `firebase_options.dart`:**
```dart
// Replace these placeholder values with your actual Firebase config:
apiKey: 'your-actual-api-key'
appId: '1:123456789:android:abcdef123456'
messagingSenderId: '123456789'
projectId: 'your-project-id'
storageBucket: 'your-project-id.appspot.com'
```

**Get these values from:**
1. Firebase Console → Project Settings → General tab
2. Scroll down to "Your apps" section
3. Click on your Android app
4. Copy the configuration values

## After Configuration

### 1. Clean and rebuild:
```bash
flutter clean
flutter pub get
```

### 2. Test the app:
```bash
flutter run
```

### 3. Verify Firebase connection:
- App should start without Firebase errors
- Check debug console for "Firebase initialized successfully"

## Troubleshooting

**If you see Firebase errors:**
1. Verify `google-services.json` is in correct location
2. Check package name matches exactly: `com.localpulse.authority.local_pulse_authority`
3. Ensure Firebase services are enabled in console
4. Run `flutter clean && flutter pub get`

**Common Issues:**
- Wrong package name in Firebase console
- `google-services.json` in wrong folder
- Firebase services not enabled
- Network connectivity issues