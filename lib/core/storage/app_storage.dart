import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  static late SharedPreferences _prefs;

  // Call this once during app startup (e.g. in main())
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> saveString(String key, String value) async {
    await _ensureInitialized();
    await _prefs.setString(key, value);
  }

  static Future<void> saveBoolean(String key, bool value) async {
    await _ensureInitialized();
    await _prefs.setBool(key, value);
  }

  static Future<bool?> getBoolean(String key) async {
    await _ensureInitialized();
    return _prefs.getBool(key);
  }

  static Future<String?> getString(String key) async {
    await _ensureInitialized();
    return _prefs.getString(key);
  }

  static Future<void> saveObject(
    String key,
    Map<String, dynamic> object,
  ) async {
    final jsonString = jsonEncode(object);
    await saveString(key, jsonString);
  }

  static Future<T?> getObject<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final jsonString = await getString(key);
    if (jsonString == null) return null;

    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return fromJson(map);
  }

  static Future<void> remove(String key) async {
    await _ensureInitialized();
    await _prefs.remove(key);
  }

  static Future<void> clearAllDataFromSharedPrefs() async {
    await _ensureInitialized();
    await _prefs.clear();
  }

  static Future<void> _ensureInitialized() async {
    // Just to safeguard against accidental use without init
    if (!(_prefs is SharedPreferences)) {
      _prefs = await SharedPreferences.getInstance();
    }
  }
}
