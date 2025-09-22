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
    // ignore: unnecessary_null_comparison
    if (_prefs == null) {
      throw Exception(
        "AppStorage not initialized. Call AppStorage.init() first.",
      );
    }
  }

  static Future<void> clearAllExcept(String keyToKeep) async {
    await _ensureInitialized();

    // Save the value of the key to keep
    final valueToKeep = _prefs.get(keyToKeep);

    // Clear all preferences
    await _prefs.clear();

    // Restore the kept key value (if it existed before)
    if (valueToKeep != null) {
      if (valueToKeep is String) {
        await _prefs.setString(keyToKeep, valueToKeep);
      } else if (valueToKeep is bool) {
        await _prefs.setBool(keyToKeep, valueToKeep);
      } else if (valueToKeep is int) {
        await _prefs.setInt(keyToKeep, valueToKeep);
      } else if (valueToKeep is double) {
        await _prefs.setDouble(keyToKeep, valueToKeep);
      } else if (valueToKeep is List<String>) {
        await _prefs.setStringList(keyToKeep, valueToKeep);
      }
    }
  }
}
