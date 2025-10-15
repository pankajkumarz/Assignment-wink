@echo off
echo Setting up API keys for Local Pulse Android Apps...

REM Copy Android API keys for both apps
if exist "config\android_keys.xml" (
    copy "config\android_keys.xml" "local_pulse_citizen\android\app\src\main\res\values\api_keys.xml"
    copy "config\android_keys.xml" "local_pulse_authority\android\app\src\main\res\values\api_keys.xml"
    echo ✅ Android API keys copied to both apps
) else (
    echo ❌ config\android_keys.xml not found. Please copy from android_keys.example.xml
)

REM Check if API keys file exists
if exist "config\api_keys.json" (
    echo ✅ API keys configuration found
) else (
    echo ❌ config\api_keys.json not found. Please copy from api_keys.example.json
)

echo.
echo 📱 Android-only setup complete!
echo 🚀 You can now run your Android apps:
echo    - Citizen App: flutter run -t lib/main_minimal.dart -d RZCW114RM4D
echo    - Authority App: flutter run -d RZCW114RM4D
echo.
pause