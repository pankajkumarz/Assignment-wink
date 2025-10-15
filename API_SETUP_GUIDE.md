# 🔐 API Keys Setup Guide - Android Only

This project uses **external configuration files** for all API keys to keep sensitive information secure and out of version control.

## 📁 File Structure (Android Only)
```
Assignment-wink/
├── config/
│   ├── api_keys.json          # ❌ Your actual API keys (NOT committed)
│   ├── api_keys.example.json  # ✅ Template file (safe to commit)
│   ├── android_keys.xml       # ❌ Android API keys (NOT committed)
│   ├── android_keys.example.xml # ✅ Android template (safe to commit)
│   ├── development.json       # ✅ Dev environment config
│   └── production.json        # ✅ Prod environment config
├── local_pulse_citizen/
│   └── android/               # ✅ Android app only
└── local_pulse_authority/
    └── android/               # ✅ Android authority app only
```

## 🚀 Quick Setup (5 minutes)

### Step 1: Copy Template Files
```bash
# Navigate to config directory
cd Assignment-wink/config

# Copy templates to actual files
copy api_keys.example.json api_keys.json
copy android_keys.example.xml android_keys.xml
```

### Step 2: Add Your API Keys

#### In `config/api_keys.json`:
```json
{
  "google_maps_api_key": "AIzaSyC...",  // Your Google Maps key
  "firebase_api_key": "AIzaSyB...",     // Your Firebase key
  "firebase_project_id": "local-pulse-app",
  // ... other keys
}
```

#### In `config/android_keys.xml`:
```xml
<string name="google_maps_api_key">AIzaSyC...</string>
```

## 🔑 Required API Keys (Android Only)

| Service | Required | Where to Get |
|---------|----------|--------------|
| **Google Maps Android SDK** | ✅ Yes | [Google Cloud Console](https://console.cloud.google.com/) |
| **Firebase Android** | ✅ Yes | [Firebase Console](https://console.firebase.google.com/) |
| **WhatsApp Business** | ❌ Optional | [WhatsApp Business API](https://business.whatsapp.com/) |

## 🛡️ Security Features (Android Focused)

- ✅ **No API keys in source code**
- ✅ **Android-specific configuration**
- ✅ **Environment-specific configurations**
- ✅ **Template files for easy setup**
- ✅ **Comprehensive .gitignore**
- ✅ **Development vs Production configs**
- ✅ **Android-only build optimization**

## 🔧 For New Developers

1. **Clone the repository**
2. **Copy template files** (see Step 1 above)
3. **Get API keys** from team lead or create your own
4. **Never commit** the actual API key files
5. **Only commit** template (.example) files

## 🚀 For Production Deployment

Use environment variables or CI/CD secrets:
```bash
# Set environment variables
export GOOGLE_MAPS_API_KEY="your_key_here"
export FIREBASE_PROJECT_ID="your_project_id"

# Or use CI/CD secrets in GitHub Actions, etc.
```

## ⚠️ Important Notes

- **Never commit** `api_keys.json`, `android_keys.xml`, or `ios_keys.plist`
- **Always commit** `.example` template files
- **Use different keys** for development and production
- **Rotate keys regularly** for security

## 🆘 If You Accidentally Commit API Keys

1. **Immediately rotate** the exposed keys
2. **Remove from git history**: `git filter-branch` or BFG Repo-Cleaner
3. **Update .gitignore** to prevent future commits
4. **Generate new keys** and update configuration files

---

**🔒 Your API keys are now secure and separate from your code!**