import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppService {
  static late SharedPreferences _prefs;
  static Map<String, dynamic> _config = {};
  
  // API Keys - YOU NEED TO SET THESE
  static String get googleMapsApiKey => _config['google_maps_api_key'] ?? 'YOUR_GOOGLE_MAPS_API_KEY';
  static String get firebaseProjectId => _config['firebase_project_id'] ?? 'YOUR_FIREBASE_PROJECT_ID';
  
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadConfig();
  }
  
  static Future<void> _loadConfig() async {
    try {
      // Try to load from config file
      final configString = await rootBundle.loadString('config/api_keys.json');
      _config = json.decode(configString);
    } catch (e) {
      print('Config file not found, using default values');
      // Set default config
      _config = {
        'google_maps_api_key': 'demo_key',
        'firebase_project_id': 'local-pulse-demo',
        'firebase_api_key': 'demo_firebase_key',
      };
    }
  }
  
  // User preferences
  static bool get isFirstLaunch => _prefs.getBool('first_launch') ?? true;
  static Future<void> setFirstLaunch(bool value) => _prefs.setBool('first_launch', value);
  
  static String get userCity => _prefs.getString('user_city') ?? 'Delhi';
  static Future<void> setUserCity(String city) => _prefs.setString('user_city', city);
  
  static bool get notificationsEnabled => _prefs.getBool('notifications') ?? true;
  static Future<void> setNotifications(bool enabled) => _prefs.setBool('notifications', enabled);
}