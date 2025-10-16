@echo off
echo Installing dependencies...
cd local_pulse_citizen
flutter pub get
echo.
echo Dependencies installed! Now you can run:
echo flutter run -t lib/main_full.dart -d RZCW114RM4D
echo.
pause