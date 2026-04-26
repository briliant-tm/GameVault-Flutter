import '../models/models.dart';
import 'api_client.dart';

class AuthService {
  AuthService(this._api);
  final ApiClient _api;

  Future<User> login(String identifier, String password) async {
    final res = await _api.dio.post('/api/auth/login', data: {
      'identifier': identifier,
      'password': password,
    });
    return _api.unwrap(res, (d) => User.fromJson(d['user'] as Map<String, dynamic>));
  }

  Future<User> register({
    required String username,
    required String email,
    required String password,
    String? nickname,
  }) async {
    final res = await _api.dio.post('/api/auth/register', data: {
      'username': username,
      'email': email,
      'password': password,
      if (nickname != null && nickname.isNotEmpty) 'nickname': nickname,
    });
    return _api.unwrap(res, (d) => User.fromJson(d['user'] as Map<String, dynamic>));
  }

  Future<User?> me() async {
    final res = await _api.dio.get('/api/auth/me');
    if (res.statusCode == 401) return null;
    try {
      return _api.unwrap(res, (d) => User.fromJson(d['user'] as Map<String, dynamic>));
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await _api.dio.post('/api/auth/logout');
    } catch (_) {}
    await _api.clearCookies();
  }

  Future<User> updateAccount({String? nickname, String? currentPassword, String? newPassword}) async {
    final res = await _api.dio.put('/api/account', data: {
      if (nickname != null) 'nickname': nickname,
      if (currentPassword != null) 'currentPassword': currentPassword,
      if (newPassword != null) 'newPassword': newPassword,
    });
    return _api.unwrap(res, (d) => User.fromJson(d['user'] as Map<String, dynamic>));
  }

  Future<void> deleteAccount(String password) async {
    final res = await _api.dio.delete('/api/account', data: {'password': password});
    if (res.data is Map && res.data['success'] != true) {
      throw ApiException(res.data['error']?.toString() ?? 'Gagal menghapus akun');
    }
    await _api.clearCookies();
  }
}
