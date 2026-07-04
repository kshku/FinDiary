import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _accessExpKey = 'access_expires_at';
  static const _refreshExpKey = 'refresh_expires_at';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required int accessExpiresAt,
    required int refreshExpiresAt,
  }) async {
    await Future.wait([
      _storage.write(key: _accessKey, value: accessToken),
      _storage.write(key: _refreshKey, value: refreshToken),
      _storage.write(key: _accessExpKey, value: accessExpiresAt.toString()),
      _storage.write(key: _refreshExpKey, value: refreshExpiresAt.toString()),
    ]);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessKey);
  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);

  Future<bool> isAccessTokenValid() async {
    final expStr = await _storage.read(key: _accessExpKey);
    if (expStr == null) return false;
    final exp = int.tryParse(expStr);
    if (exp == null) return false;
    return DateTime.now().millisecondsSinceEpoch < exp * 1000;
  }

  Future<void> clearTokens() async {
    await _storage.deleteAll();
  }
}
