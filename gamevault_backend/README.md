# 🎮 GameVault Backend (Dart)

Simple REST API backend untuk GameVault Flutter menggunakan **pure Dart** dengan framework `shelf`.

## 🚀 Quick Start

### Prerequisites
- Dart SDK >=3.4.0

### Installation & Run

```bash
# Masuk ke folder backend
cd gamevault_backend

# Install dependencies
dart pub get

# Jalankan server
dart run bin/server.dart
```

Server akan berjalan di: **http://localhost:3000**

## 📚 API Endpoints

### Authentication
- `POST /api/auth/login` - Login user
- `POST /api/auth/register` - Register user baru
- `GET /api/auth/me` - Cek session
- `POST /api/auth/logout` - Logout

### Games
- `GET /api/games` - List games (support query: search, genre, platform)
- `GET /api/games/:id` - Detail game
- `POST /api/games` - Buat game
- `PUT /api/games/:id` - Update game
- `DELETE /api/games/:id` - Hapus game

## 🧪 Testing

Gunakan Postman atau curl:

```bash
# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"identifier":"user1","password":"password123"}'

# Get all games
curl http://localhost:3000/api/games

# Search games
curl "http://localhost:3000/api/games?search=Elden&genre=RPG"
```

## 📝 Default Users

| Username | Password | Email |
|----------|----------|-------|
| user1 | password123 | user1@example.com |

## 📦 Mock Data

Backend sudah include 3 games default:
1. Elden Ring (RPG, PC)
2. The Legend of Zelda (Adventure, Switch)
3. Baldur's Gate 3 (RPG, PC)

## 🔧 Tech Stack

- **Dart** - Pure Dart implementation
- **Shelf** - Lightweight web framework
- **shelf_router** - Routing
- **dart_jsonwebtoken** - JWT support (future)

## 📄 Response Format

Semua response dalam format envelope:

```json
{
  "success": true,
  "data": { ... },
  "error": null,
  "message": null
}
```
