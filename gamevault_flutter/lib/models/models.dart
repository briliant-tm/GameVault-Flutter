class User {
  final int id;
  final String username;
  final String email;
  final String? nickname;
  final String? createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.nickname,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: (j['id'] as num).toInt(),
        username: j['username'] as String,
        email: j['email'] as String,
        nickname: j['nickname'] as String?,
        createdAt: j['created_at']?.toString(),
      );
}

class Game {
  final int id;
  final String title;
  final String genre;
  final String platform;
  final String? coverUrl;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  Game({
    required this.id,
    required this.title,
    required this.genre,
    required this.platform,
    this.coverUrl,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory Game.fromJson(Map<String, dynamic> j) => Game(
        id: (j['id'] as num).toInt(),
        title: j['title'] as String,
        genre: j['genre'] as String,
        platform: j['platform'] as String,
        coverUrl: j['cover_url'] as String?,
        notes: j['notes'] as String?,
        createdAt: j['created_at']?.toString(),
        updatedAt: j['updated_at']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'genre': genre,
        'platform': platform,
        'cover_url': coverUrl,
        'notes': notes,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}

/// Three-state UI wrapper (wajib).
sealed class UiState<T> {
  const UiState();
}

class Idle<T> extends UiState<T> { const Idle(); }
class Loading<T> extends UiState<T> { const Loading(); }
class Success<T> extends UiState<T> {
  final T data;
  const Success(this.data);
}
class Failure<T> extends UiState<T> {
  final String message;
  const Failure(this.message);
}
