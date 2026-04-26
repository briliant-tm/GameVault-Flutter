import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart';
// import 'dart:io';

// Mock database
class MockDatabase {
  static final _games = <int, Map<String, dynamic>>{
    1: {
      'id': 1,
      'title': 'Elden Ring',
      'genre': 'RPG',
      'platform': 'PC',
      'cover_url': 'https://via.placeholder.com/200?text=Elden+Ring',
      'notes': 'Masterpiece dari FromSoftware',
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    },
    2: {
      'id': 2,
      'title': 'The Legend of Zelda: Tears of the Kingdom',
      'genre': 'Adventure',
      'platform': 'Nintendo Switch',
      'cover_url': 'https://via.placeholder.com/200?text=Zelda',
      'notes': 'Open world terbaik 2023',
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    },
    3: {
      'id': 3,
      'title': 'Baldur\'s Gate 3',
      'genre': 'RPG',
      'platform': 'PC',
      'cover_url': 'https://via.placeholder.com/200?text=BG3',
      'notes': 'Story-driven RPG terbaik',
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    },
  };

  static final _users = <String, Map<String, dynamic>>{
    'user1': {
      'id': 1,
      'username': 'user1',
      'email': 'user1@example.com',
      'password': 'password123',
      'nickname': 'Gamer Pro',
    },
  };

  static List<Map<String, dynamic>> getGames({
    String? search,
    String? genre,
    String? platform,
  }) {
    var result = _games.values.toList();

    if (search != null && search.isNotEmpty) {
      result = result
          .where((g) => g['title'].toLowerCase().contains(search.toLowerCase()))
          .toList();
    }

    if (genre != null && genre.isNotEmpty) {
      result = result
          .where((g) => g['genre'].toLowerCase().contains(genre.toLowerCase()))
          .toList();
    }

    if (platform != null && platform.isNotEmpty) {
      result = result
          .where((g) =>
              g['platform'].toLowerCase().contains(platform.toLowerCase()))
          .toList();
    }

    return result;
  }

  static Map<String, dynamic>? getGame(int id) => _games[id];

  static Map<String, dynamic> createGame(Map<String, dynamic> data) {
    final id = (_games.keys.isEmpty
            ? 0
            : _games.keys.reduce((a, b) => a > b ? a : b)) +
        1;
    final game = {
      'id': id,
      'title': data['title'],
      'genre': data['genre'],
      'platform': data['platform'],
      'cover_url': data['cover_url'],
      'notes': data['notes'],
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
    _games[id] = game;
    return game;
  }

  static Map<String, dynamic>? updateGame(int id, Map<String, dynamic> data) {
    if (!_games.containsKey(id)) return null;
    final game = _games[id]!;
    game['title'] = data['title'] ?? game['title'];
    game['genre'] = data['genre'] ?? game['genre'];
    game['platform'] = data['platform'] ?? game['platform'];
    game['cover_url'] = data['cover_url'] ?? game['cover_url'];
    game['notes'] = data['notes'] ?? game['notes'];
    game['updated_at'] = DateTime.now().millisecondsSinceEpoch;
    return game;
  }

  static bool deleteGame(int id) {
    return _games.remove(id) != null;
  }

  static Map<String, dynamic>? getUser(String username) {
    return _users[username];
  }

  static Map<String, dynamic> createUser(Map<String, dynamic> data) {
    final user = {
      'id': _users.length + 1,
      'username': data['username'],
      'email': data['email'],
      'password': data['password'],
      'nickname': data['nickname'] ?? data['username'],
    };
    _users[data['username']] = user;
    return user;
  }
}

// Response helper
Map<String, dynamic> apiResponse({
  required bool success,
  dynamic data,
  String? error,
  String? message,
}) {
  return {
    'success': success,
    if (data != null) 'data': data,
    if (error != null) 'error': error,
    if (message != null) 'message': message,
  };
}

// Main server
void main() async {
  const jwtSecret = 'your-secret-key-change-this';

  final router = Router();

  // === AUTH Routes ===
  router.post('/api/auth/login', (Request request) async {
    final body = jsonDecode(await request.readAsString());
    final username = body['identifier'] as String?;
    final password = body['password'] as String?;

    if (username == null || password == null) {
      return Response.badRequest(
        body: jsonEncode(apiResponse(
          success: false,
          error: 'Missing username or password',
        )),
      );
    }

    final user = MockDatabase.getUser(username);
    if (user == null || user['password'] != password) {
      return Response.unauthorized(
        jsonEncode(apiResponse(
          success: false,
          error: 'Unauthorized',
        )),
        headers: {'Content-Type': 'application/json'},
      );
    }

    return Response.ok(
      jsonEncode(apiResponse(
        success: true,
        data: {
          'user': {
            'id': user['id'],
            'username': user['username'],
            'email': user['email'],
            'nickname': user['nickname'],
          },
        },
      )),
      headers: {
        'Content-Type': 'application/json',
        'Set-Cookie':
            'access_token=dummy_jwt_token; Path=/; HttpOnly; SameSite=Lax',
      },
    );
  });

  router.post('/api/auth/register', (Request request) async {
    final body = jsonDecode(await request.readAsString());
    final username = body['username'] as String?;
    final email = body['email'] as String?;
    final password = body['password'] as String?;

    if (username == null || email == null || password == null) {
      return Response.badRequest(
        body: jsonEncode(apiResponse(
          success: false,
          error: 'Missing required fields',
        )),
      );
    }

    if (MockDatabase.getUser(username) != null) {
      return Response.badRequest(
        body: jsonEncode(apiResponse(
          success: false,
          error: 'User already exists',
        )),
      );
    }

    final user = MockDatabase.createUser(body);

    return Response.ok(
      jsonEncode(apiResponse(
        success: true,
        data: {
          'user': {
            'id': user['id'],
            'username': user['username'],
            'email': user['email'],
            'nickname': user['nickname'],
          },
        },
      )),
      headers: {
        'Content-Type': 'application/json',
        'Set-Cookie':
            'access_token=dummy_jwt_token; Path=/; HttpOnly; SameSite=Lax',
      },
    );
  });

  router.get('/api/auth/me', (Request request) async {
    final cookies = request.headers['cookie'];
    if (cookies == null || !cookies.contains('access_token')) {
      return Response.unauthorized(
        jsonEncode(apiResponse(
          success: false,
          error: 'Unauthorized',
        )),
        headers: {'Content-Type': 'application/json'},
      );
    }

    // Mock user
    return Response.ok(
      jsonEncode(apiResponse(
        success: true,
        data: {
          'user': {
            'id': 1,
            'username': 'user1',
            'email': 'user1@example.com',
            'nickname': 'Gamer Pro',
          },
        },
      )),
      headers: {'Content-Type': 'application/json'},
    );
  });

  router.post('/api/auth/logout', (Request request) async {
    return Response.ok(
      jsonEncode(apiResponse(success: true)),
      headers: {
        'Content-Type': 'application/json',
        'Set-Cookie': 'access_token=; Path=/; Max-Age=0',
      },
    );
  });

  // === GAMES Routes ===
  router.get('/api/games', (Request request) async {
    final search = request.url.queryParameters['search'];
    final genre = request.url.queryParameters['genre'];
    final platform = request.url.queryParameters['platform'];

    final games =
        MockDatabase.getGames(search: search, genre: genre, platform: platform);

    return Response.ok(
      jsonEncode(apiResponse(
        success: true,
        data: {'games': games},
      )),
      headers: {'Content-Type': 'application/json'},
    );
  });

  router.get('/api/games/<id>', (Request request, String id) async {
    final gameId = int.tryParse(id);
    if (gameId == null) {
      return Response.badRequest(
        body: jsonEncode(apiResponse(
          success: false,
          error: 'Invalid game ID',
        )),
      );
    }

    final game = MockDatabase.getGame(gameId);
    if (game == null) {
      return Response.notFound(
        jsonEncode(apiResponse(
          success: false,
          error: 'Game not found',
        )),
      );
    }

    return Response.ok(
      jsonEncode(apiResponse(
        success: true,
        data: {'game': game},
      )),
      headers: {'Content-Type': 'application/json'},
    );
  });

  router.post('/api/games', (Request request) async {
    final body = jsonDecode(await request.readAsString());

    try {
      final game = MockDatabase.createGame(body);
      return Response.ok(
        jsonEncode(apiResponse(
          success: true,
          data: {'game': game},
        )),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.badRequest(
        body: jsonEncode(apiResponse(
          success: false,
          error: e.toString(),
        )),
      );
    }
  });

  router.put('/api/games/<id>', (Request request, String id) async {
    final gameId = int.tryParse(id);
    if (gameId == null) {
      return Response.badRequest(
        body: jsonEncode(apiResponse(
          success: false,
          error: 'Invalid game ID',
        )),
      );
    }

    final body = jsonDecode(await request.readAsString());
    final game = MockDatabase.updateGame(gameId, body);

    if (game == null) {
      return Response.notFound(
        jsonEncode(apiResponse(
          success: false,
          error: 'Game not found',
        )),
      );
    }

    return Response.ok(
      jsonEncode(apiResponse(
        success: true,
        data: {'game': game},
      )),
      headers: {'Content-Type': 'application/json'},
    );
  });

  router.delete('/api/games/<id>', (Request request, String id) async {
    final gameId = int.tryParse(id);
    if (gameId == null) {
      return Response.badRequest(
        body: jsonEncode(apiResponse(
          success: false,
          error: 'Invalid game ID',
        )),
      );
    }

    final success = MockDatabase.deleteGame(gameId);
    if (!success) {
      return Response.notFound(
        jsonEncode(apiResponse(
          success: false,
          error: 'Game not found',
        )),
      );
    }

    return Response.ok(
      jsonEncode(apiResponse(success: true)),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // 404 handler
  router.all('/<ignored|.*>', (Request request) {
    return Response.notFound(
      jsonEncode(apiResponse(
        success: false,
        error: 'Not found',
      )),
    );
  });

  // CORS middleware
  final handler = (Request request) {
    if (request.method == 'OPTIONS') {
      return Response.ok(null, headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      });
    }
    return router(request);
  };

  // CORS middleware yang sudah diperbaiki
  final corsHandler = (Request request) async {
    if (request.method == 'OPTIONS') {
      return Response.ok(null, headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
      });
    }

    // Tambahkan await di sini agar 'response' bertipe Response, bukan Object/Future
    final response = await router(request);

    return response.change(headers: {
      ...response.headers,
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    });
  };

  const port = 3000;
  final server = await serve(corsHandler, '0.0.0.0', port);

  print('🎮 GameVault Backend running on http://your-pc-ip:$port');
  print('📚 API dokumentasi tersedia di backend folder');
}
