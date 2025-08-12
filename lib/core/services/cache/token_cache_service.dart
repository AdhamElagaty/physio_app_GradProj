import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../utils/date_utils.dart';

class TokenCacheService {
  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'access_token';
  static const _accessTokenExpiresOnKey = 'access_token_expires_on';
  static const _refreshTokenKey = 'refresh_token';
  static const _refreshTokenExpiresOnKey = 'refresh_token_expires_on';

  TokenCacheService(this._storage);

  Future<void> saveTokens({
    required String accessToken,
    required DateTime accessTokenExpiresOn,
    required String refreshToken,
    required DateTime refreshTokenExpiresOn,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(
      key: _accessTokenExpiresOnKey,
      value: accessTokenExpiresOn.toIso8601String(),
    );
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(
      key: _refreshTokenExpiresOnKey,
      value: refreshTokenExpiresOn.toIso8601String(),
    );
  }

  Future<bool> hasToken() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    
    return accessToken != null && refreshToken != null;
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Retrieves the expiration date of the access token.
  Future<DateTime?> getAccessTokenExpiresOn() async {
    final expiresOnString = await _storage.read(key: _accessTokenExpiresOnKey);
    if (expiresOnString == null) return null;
    return DateUtils.parseBackendDate(expiresOnString);
  }

  Future<DateTime?> getRefreshTokenExpiresOn() async {
    final expiresOnString = await _storage.read(key: _refreshTokenExpiresOnKey);
    if (expiresOnString == null) return null;
    return DateUtils.parseBackendDate(expiresOnString);
  }

  Future<bool> isAccessTokenExpired() async {
    final expiresOn = await getAccessTokenExpiresOn();
    if (expiresOn == null) {
      return true;
    }
    return DateTime.now().isAfter(expiresOn);
  }

  Future<bool> isRefreshTokenExpired() async {
    final expiresOn = await getRefreshTokenExpiresOn();
    if (expiresOn == null) {
      return true;
    }
    return DateTime.now().isAfter(expiresOn);
  }

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _accessTokenExpiresOnKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _refreshTokenExpiresOnKey);
  }
}
