import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Ganti BASE_URL ke URL backend Next.js GameVault Anda.
/// - Emulator Android + backend di laptop: http://10.0.2.2:3000
/// - Device fisik: pakai IP laptop atau URL deploy (contoh https://your.vercel.app)
const String kBaseUrl = 'http://192.168.1.10:3000';

class ApiClient {
  ApiClient._(this.dio, this.cookieJar);

  final Dio dio;
  final PersistCookieJar cookieJar;

  static Future<ApiClient> create() async {
    final dir = await getApplicationDocumentsDirectory();
    final jar = PersistCookieJar(storage: FileStorage(p.join(dir.path, '.cookies')));
    final dio = Dio(BaseOptions(
      baseUrl: kBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
      validateStatus: (_) => true,
    ));
    dio.interceptors.add(CookieManager(jar));
    return ApiClient._(dio, jar);
  }

  Future<void> clearCookies() => cookieJar.deleteAll();

  /// Helper: parsing envelope `{success, data, error, message}`.
  T unwrap<T>(Response res, T Function(Map<String, dynamic>) onData) {
    final body = res.data;
    if (body is! Map) {
      throw ApiException('Respons tidak valid (${res.statusCode})');
    }
    final success = body['success'] == true;
    if (!success) {
      throw ApiException(body['error']?.toString() ?? 'Permintaan gagal (${res.statusCode})');
    }
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw ApiException('Field data tidak ditemukan');
    }
    return onData(data);
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}
