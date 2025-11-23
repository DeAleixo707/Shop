import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Storestorage {
  static Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  static Future<void> saveMap(String key, Map<String, dynamic> value) async {
    saveString(key, jsonEncode(value));
  }

  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<Map<String, dynamic>> getMap(String key) async {
    Map<String, dynamic> map = jsonDecode(await getString(key) ?? '');
    return map;
  }
  static Future<bool?> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
    return null;
  }

}
