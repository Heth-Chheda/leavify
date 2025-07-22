import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  // Save a particular string
  static Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // function to get the string value from the shared prefereneces
  // Note: this returns a string value only !!
  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  /// Save amap/object by converting it to JSON string
  static Future<void> saveObject(
    String key,
    Map<String, dynamic> object,
  ) async {
    final jsonString = jsonEncode(object);
    await saveString(key, jsonString);
  }

  // Function to get the object from the shared prefs.
  static Future<T?> getObject<T>(
    String key,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final jsonString = await getString(key);
    if (jsonString == null) return null;

    final map = jsonDecode(jsonString) as Map<String, dynamic>;
    return fromJson(map);
  }

  // Remove a key from the shared prefs.
  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // clearing all the data from the storage. / shared prefs
  static Future<void> clearAllDataFromSharedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
