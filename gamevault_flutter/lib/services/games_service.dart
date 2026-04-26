import '../models/models.dart';
import 'api_client.dart';

class GamesService {
  GamesService(this._api);
  final ApiClient _api;

  Future<List<Game>> list({String? search, String? genre, String? platform}) async {
    final res = await _api.dio.get('/api/games', queryParameters: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (genre != null && genre.isNotEmpty) 'genre': genre,
      if (platform != null && platform.isNotEmpty) 'platform': platform,
    });
    return _api.unwrap(res, (d) {
      final items = (d['games'] as List).cast<Map<String, dynamic>>();
      return items.map(Game.fromJson).toList();
    });
  }

  Future<Game> get(int id) async {
    final res = await _api.dio.get('/api/games/$id');
    return _api.unwrap(res, (d) => Game.fromJson(d['game'] as Map<String, dynamic>));
  }

  Future<Game> create({
    required String title,
    required String genre,
    required String platform,
    String? coverUrl,
    String? notes,
  }) async {
    final res = await _api.dio.post('/api/games', data: {
      'title': title,
      'genre': genre,
      'platform': platform,
      'cover_url': coverUrl,
      'notes': notes,
    });
    return _api.unwrap(res, (d) => Game.fromJson(d['game'] as Map<String, dynamic>));
  }

  Future<Game> update(int id, {
    required String title,
    required String genre,
    required String platform,
    String? coverUrl,
    String? notes,
  }) async {
    final res = await _api.dio.put('/api/games/$id', data: {
      'title': title,
      'genre': genre,
      'platform': platform,
      'cover_url': coverUrl,
      'notes': notes,
    });
    return _api.unwrap(res, (d) => Game.fromJson(d['game'] as Map<String, dynamic>));
  }

  Future<void> delete(int id) async {
    final res = await _api.dio.delete('/api/games/$id');
    if (res.data is Map && res.data['success'] != true) {
      throw ApiException(res.data['error']?.toString() ?? 'Gagal menghapus');
    }
  }
}
