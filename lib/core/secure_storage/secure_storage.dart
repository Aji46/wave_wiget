import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  // Store access token
  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  // Retrieve access token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Store refresh token
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: 'refresh_token', value: token);
  }

  // Retrieve refresh token
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  // Delete tokens (on logout)
  static Future<void> clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }
}
