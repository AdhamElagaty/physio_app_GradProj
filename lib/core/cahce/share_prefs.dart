import 'dart:convert';
import 'package:gradproject/features/auth/data/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Make sure this points to your Token model

class CacheHelper {
  static SharedPreferences? _preferences;

  /// Initialize SharedPreferences
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  /// Generic Save
  static Future<void> setData<T>(String key, T value) async {
    if (_preferences == null)
      throw Exception("SharedPreferences not initialized");

    if (value is String) {
      await _preferences!.setString(key, value);
    } else if (value is int) {
      await _preferences!.setInt(key, value);
    } else if (value is bool) {
      await _preferences!.setBool(key, value);
    } else if (value is double) {
      await _preferences!.setDouble(key, value);
    } else if (value is List<String>) {
      await _preferences!.setStringList(key, value);
    } else {
      throw Exception("Unsupported type");
    }
  }

  /// Generic Get
  static T? getData<T>(String key) {
    if (_preferences == null)
      throw Exception("SharedPreferences not initialized");

    if (T == String) {
      return _preferences!.getString(key) as T?;
    } else if (T == int) {
      return _preferences!.getInt(key) as T?;
    } else if (T == bool) {
      return _preferences!.getBool(key) as T?;
    } else if (T == double) {
      return _preferences!.getDouble(key) as T?;
    } else if (T == List<String>) {
      return _preferences!.getStringList(key) as T?;
    } else {
      throw Exception("Unsupported type");
    }
  }

  /// Save token as JSON string
  static Future<void> saveToken(Token token) async {
    final jsonString = json.encode({
      'value': token.value,
      'expiresOn': token.expiresOn,
    });
    await _preferences!.setString('token', jsonString);
  }

  /// Get token
  static Token? getToken() {
    final jsonString = _preferences!.getString('token');
    if (jsonString == null) return null;
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return Token.fromJson(jsonMap);
  }

  /// Remove key
  static Future<void> removeData(String key) async {
    if (_preferences == null)
      throw Exception("SharedPreferences not initialized");
    await _preferences!.remove(key);
  }
}
