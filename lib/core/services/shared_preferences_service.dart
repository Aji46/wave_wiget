// import 'package:shared_preferences/shared_preferences.dart';

// class SharedPreferencesService {
//   final SharedPreferences _prefs;

//   SharedPreferencesService(this._prefs);

//   // Save a String value
//   Future<bool> saveString(String key, String value) async {
//     return await _prefs.setString(key, value);
//   }

//   // Retrieve a String value
//   String? getString(String key) {
//     return _prefs.getString(key);
//   }

//   // Save an Integer value
//   Future<bool> saveInt(String key, int value) async {
//     return await _prefs.setInt(key, value);
//   }

//   // Retrieve an Integer value
//   int? getInt(String key) {
//     return _prefs.getInt(key);
//   }

//   // Save a Boolean value
//   Future<bool> saveBool(String key, bool value) async {
//     return await _prefs.setBool(key, value);
//   }

//   // Retrieve a Boolean value
//   bool? getBool(String key) {
//     return _prefs.getBool(key);
//   }

//   // Remove a value by key
//   Future<bool> remove(String key) async {
//     return await _prefs.remove(key);
//   }

//   // Clear all stored data
//   Future<bool> clearAll() async {
//     return await _prefs.clear();
//   }
// }
