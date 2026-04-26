# 🎮 GameVault - Full Stack Dart Application

Aplikasi mobile **GameVault** menggunakan **pure Dart** untuk frontend (Flutter) dan backend (Shelf).

## 📁 Struktur Project

```
GameVault/
├── gamevault_flutter/     # Flutter Frontend (Mobile App)
│   ├── lib/
│   ├── android/
│   ├── pubspec.yaml
│   └── README.md
│
├── gamevault_backend/     # Dart Backend (REST API)
│   ├── bin/
│   ├── lib/
│   ├── pubspec.yaml
│   └── README.md
│
└── README.md              # (File ini)
```

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone <repository-url>
cd gamevault
```

### 2. Backend Setup (Terminal 1)
```bash
cd gamevault_backend
dart pub get
dart run bin/server.dart
```

Server berjalan di: **http://localhost:3000**

### 3. Frontend Setup (Terminal 2)
```bash
cd gamevault_flutter
flutter pub get
flutter run
```

## 📋 Fitur Utama

- Flutter + Android 13 compatibility
- Provider State Management
- Three-state UI (Loading, Error, Success)
- REST API Integration
- JWT Authentication
- Layered Architecture (Models, Services, Providers, Screens)
- Full CRUD Operations
- Search & Filter Games
- Smooth Animations & Transitions
- Responsive UI/UX
- Pure Dart Backend
- Git Version Control

## 🔐 Authentication

Default test user:
- **Username:** user1
- **Password:** password123

## 📚 API Documentation

Lihat [gamevault_backend/README.md](gamevault_backend/README.md) untuk detail endpoint.

## 🛠️ Tech Stack

### Frontend
- **Flutter** 3.22.0+
- **Provider** 6.1.2 (State Management)
- **Dio** 5.7.0 (HTTP Client)
- **Cached Network Image** 3.4.1
- **SQLite** untuk local storage

### Backend
- **Dart** 3.4.0+
- **Shelf** 1.4.1 (Web Framework)
- **shelf_router** untuk routing
- **dart_jsonwebtoken** untuk JWT

## 📱 Platform Support

- **Android** 5.0+ (minSdk 21)
- **Target:** Android 13+ (Android 33)

## 🎯 Project Requirements (Sesuai PDF)

| Requirement | Status |
|-------------|--------|
| Flutter Framework | ✅ |
| Android Platform | ✅ |
| REST API | ✅ (Dart Backend) |
| JWT Authentication | ✅ |
| Provider State Management | ✅ |
| Three-State UI | ✅ |
| Layered Architecture | ✅ |
| CRUD Operations | ✅ |
| Search/Filter | ✅ |
| Animations | ✅ |
| Git Version Control | ✅ |

## 🏗️ Architecture

```
Frontend (Flutter)
├── Models/           # Data models
├── Services/         # API clients, local storage
├── Providers/        # State management
├── Screens/          # UI pages
└── Widgets/          # Reusable components

Backend (Dart)
├── bin/server.dart   # Main entry point
└── MockDatabase      # In-memory data storage
```

## 📝 Development Notes

- Backend menggunakan mock database (in-memory)
- Untuk production, implementasikan database sebenarnya (PostgreSQL, MongoDB, dll)
- JWT implementation sudah dipersiapkan, tinggal implementasikan di backend
- CORS sudah enabled untuk akses dari emulator/device

## 🚀 Running in Production

### Backend
```bash
dart run bin/server.dart --release
```

### Frontend (APK Release)
```bash
flutter build apk --release
```

## 📞 Testing

### Manual Testing
Gunakan Postman atau curl untuk test API endpoints.

### Widget Testing
```bash
flutter test
```

## 📄 License

Educational Project - Tugas 2 Pengembangan Aplikasi Berbasis Platform

## 👨‍💻 Author

[Your Name]

## 📞 Support

Jika ada issues atau questions, buat issue di repository atau hubungi instructor.

---

**Happy Coding!** 🚀
