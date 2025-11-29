import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';

  /// Stores both the access and refresh tokens securely.
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// Retrieves the access token.
  static Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  /// Retrieves the refresh token.
  static Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  /// Deletes all stored tokens.
  static Future<void> deleteTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}