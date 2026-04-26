import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';

/// Local-only store untuk mode Guest: SQLite + flag expiry 14 hari.
class GuestStore {
  GuestStore._(this._db, this._prefs);

  final Database _db;
  final SharedPreferences _prefs;

  static const _kIsGuest = 'is_guest';
  static const _kExpires = 'guest_expires_at';
  static const _kNickname = 'guest_nickname';
  static const _twoWeeks = Duration(days: 14);

  static Future<GuestStore> create() async {
    final dir = await getApplicationDocumentsDirectory();
    final db = await openDatabase(
      p.join(dir.path, 'gamevault_guest.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE guest_games (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            genre TEXT NOT NULL,
            platform TEXT NOT NULL,
            cover_url TEXT,
            notes TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
      },
    );
    final prefs = await SharedPreferences.getInstance();
    return GuestStore._(db, prefs);
  }

  bool get isGuest => _prefs.getBool(_kIsGuest) ?? false;
  int get expiresAt => _prefs.getInt(_kExpires) ?? 0;
  String get nickname => _prefs.getString(_kNickname) ?? 'Guest';

  Duration get remaining {
    final ms = expiresAt - DateTime.now().millisecondsSinceEpoch;
    return ms > 0 ? Duration(milliseconds: ms) : Duration.zero;
  }

  Future<void> startGuest([String nick = 'Guest']) async {
    await _prefs.setBool(_kIsGuest, true);
    await _prefs.setString(_kNickname, nick);
    await _prefs.setInt(_kExpires,
        DateTime.now().add(_twoWeeks).millisecondsSinceEpoch);
  }

  Future<void> endGuest() async {
    await _prefs.remove(_kIsGuest);
    await _prefs.remove(_kExpires);
    await _prefs.remove(_kNickname);
  }

  Future<void> wipe() async {
    await _db.delete('guest_games');
  }

  /// Dipanggil saat app start. Kembalikan true kalau sesi guest baru saja expired & di-wipe.
  Future<bool> cleanupIfExpired() async {
    if (!isGuest) return false;
    if (expiresAt > DateTime.now().millisecondsSinceEpoch) return false;
    await wipe();
    await endGuest();
    return true;
  }

  Future<List<Game>> list({String search = '', String genre = '', String platform = ''}) async {
    final where = <String>[];
    final args = <Object>[];
    if (search.isNotEmpty) { where.add('title LIKE ?'); args.add('%$search%'); }
    if (genre.isNotEmpty) { where.add('genre LIKE ?'); args.add('%$genre%'); }
    if (platform.isNotEmpty) { where.add('platform LIKE ?'); args.add('%$platform%'); }
    final rows = await _db.query(
      'guest_games',
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args,
      orderBy: 'created_at DESC',
    );
    return rows.map((r) => Game(
      id: r['id'] as int,
      title: r['title'] as String,
      genre: r['genre'] as String,
      platform: r['platform'] as String,
      coverUrl: r['cover_url'] as String?,
      notes: r['notes'] as String?,
      createdAt: (r['created_at'] as int).toString(),
      updatedAt: (r['updated_at'] as int).toString(),
    )).toList();
  }

  Future<Game> get(int id) async {
    final rows = await _db.query('guest_games', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) throw Exception('Game tidak ditemukan');
    final r = rows.first;
    return Game(
      id: r['id'] as int,
      title: r['title'] as String,
      genre: r['genre'] as String,
      platform: r['platform'] as String,
      coverUrl: r['cover_url'] as String?,
      notes: r['notes'] as String?,
    );
  }

  Future<Game> createGame({
    required String title,
    required String genre,
    required String platform,
    String? coverUrl,
    String? notes,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = await _db.insert('guest_games', {
      'title': title, 'genre': genre, 'platform': platform,
      'cover_url': coverUrl, 'notes': notes,
      'created_at': now, 'updated_at': now,
    });
    return get(id);
  }

  Future<Game> update(int id, {
    required String title,
    required String genre,
    required String platform,
    String? coverUrl,
    String? notes,
  }) async {
    await _db.update(
      'guest_games',
      {
        'title': title, 'genre': genre, 'platform': platform,
        'cover_url': coverUrl, 'notes': notes,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?', whereArgs: [id],
    );
    return get(id);
  }

  Future<void> delete(int id) async {
    await _db.delete('guest_games', where: 'id = ?', whereArgs: [id]);
  }
}
