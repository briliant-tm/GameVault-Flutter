# GameVault — Flutter Client

Aplikasi Flutter untuk REST API GameVault (`briliant-tm/GameVault-NextJS-Local`). Memenuhi rubrik UAS:

- ✅ **Flutter** sebagai framework utama (target Android, min API 21 bawaan Flutter)
- ✅ **REST API UTS** dipakai sebagai sumber data, via `dio` + `dio_cookie_manager` sehingga cookie JWT `access_token`/`refresh_token` yang di-set backend dipertahankan secara otomatis
- ✅ **Provider** untuk state management (`AuthProvider`, `GamesProvider` + `ChangeNotifierProxyProvider`)
- ✅ **Three-state UI**: `UiState<T>` sealed class dengan `Loading`, `Failure`, `Success` — digunakan di list, detail, dan aksi mutasi
- ✅ **CRUD lengkap** (opsional, dibawa): tambah, ubah, hapus game
- ✅ **Pencarian + filter** genre & platform (debounce)
- ✅ **Animasi & transisi halaman** halus: splash rotate+pulse, `fadeSlideRoute` untuk navigasi, `AnimatedSwitcher` antar three-state, `Hero` cover game
- ✅ **Guest mode** (permintaan tambahan): SQLite lokal, auto-wipe otomatis 14 hari sejak sesi guest dimulai (lihat `GuestStore.cleanupIfExpired`)

## Struktur

```
lib/
├── main.dart                # entrypoint, MultiProvider, theme
├── models/models.dart       # User, Game, UiState sealed
├── services/
│   ├── api_client.dart      # Dio + CookieJar (JWT via httpOnly cookie)
│   ├── auth_service.dart    # login/register/logout/me/account
│   ├── games_service.dart   # CRUD games
│   └── guest_store.dart     # SQLite + SharedPreferences (expiry 14 hari)
├── providers/
│   ├── auth_provider.dart   # SessionMode: unknown/unauth/authed/guest
│   └── games_provider.dart  # list/detail/mutation state
├── widgets/
│   ├── state_widgets.dart   # LoadingView, ErrorStateView, GradientBackground
│   └── page_route.dart      # fadeSlideRoute
└── screens/
    ├── splash_screen.dart
    ├── login_screen.dart
    ├── register_screen.dart
    ├── library_screen.dart  # grid + search + filter + refresh
    ├── detail_screen.dart   # Hero cover + delete dialog
    ├── edit_screen.dart     # create/update
    └── account_screen.dart  # update profile, delete account, logout
```

## Cara Menjalankan

### 1. Siapkan Flutter
- Flutter SDK stable (>= 3.22) dan Android Studio / Android SDK
- Device Android / emulator aktif

### 2. Buat scaffold platform (penting — folder `android/`, `ios/`, dll. tidak disertakan di repo ini)
Karena repo hanya berisi `lib/` dan `pubspec.yaml`, jalankan sekali di root folder:

```bash
cd gamevault_flutter
flutter create .          # generate folder android/, ios/, linux/, dll.
flutter pub get
```

Perintah `flutter create .` aman — ia hanya menambahkan folder platform, **tidak menimpa** `lib/` atau `pubspec.yaml` yang sudah ada.

### 3. Atur URL backend
Buka `lib/services/api_client.dart`, ubah `kBaseUrl`:
- **Emulator Android + backend di laptop**: `http://10.0.2.2:3000` (default)
- **Device fisik**: pakai IP laptop di LAN atau URL deploy (Vercel, dll.)

### 4. Run
```bash
flutter run
```

## Pemetaan API (Next.js → Flutter)

| Endpoint Next.js | Kelas |
|---|---|
| `POST /api/auth/login` | `AuthService.login` |
| `POST /api/auth/register` | `AuthService.register` |
| `POST /api/auth/logout` | `AuthService.logout` |
| `GET /api/auth/me` | `AuthService.me` (dipanggil di splash) |
| `GET /api/games?search=&genre=&platform=` | `GamesService.list` |
| `GET /api/games/:id` | `GamesService.get` |
| `POST /api/games` | `GamesService.create` |
| `PUT /api/games/:id` | `GamesService.update` |
| `DELETE /api/games/:id` | `GamesService.delete` |
| `PUT /api/account` | `AuthService.updateAccount` |
| `DELETE /api/account` | `AuthService.deleteAccount` |

## Catatan Penting

- **Rubrik menyebut "cukup read data saja" untuk sumber data wajib.** Saya tetap sertakan CRUD lengkap karena Anda meminta "semua fitur yang ada di projek tersebut, dibawa ke projek android" dan CRUD terdaftar di rubrik sebagai fitur opsional (poin 4a). Kalau dosen lebih ketat, cukup sembunyikan tombol tambah/ubah/hapus di UI.
- **Guest mode** murni lokal (tidak menyentuh backend). Ketika Guest membuat game, data masuk ke SQLite lokal (`guest_games`). Semua data hilang otomatis saat `now > expires_at` (14 hari). Banner hitungan mundur tampil di Library dan Account.
- **JWT via cookie**: `CookieManager` (dari `dio_cookie_manager`) menyimpan cookie `access_token` (15 menit) dan `refresh_token` (7 hari) otomatis. Kalau access token expired, user akan dialihkan ke login — refresh-token interceptor belum saya pasang (bisa ditambahkan dengan memanggil `POST /api/auth/refresh` di Dio `onError` interceptor saat 401).
- **Backend harus accessible dari device** (bukan hanya `localhost`). Untuk deploy cepat: Vercel untuk Next.js + PlanetScale/Railway untuk MySQL.

## Checklist Rubrik

- [x] Flutter framework, target Android
- [x] REST API UTS sebagai sumber data + JWT
- [x] Provider state management
- [x] Three-state UI (loading / error / success)
- [x] CRUD penuh (opsional)
- [x] Pencarian + filter (opsional)
- [x] Animasi & transisi halaman (opsional)
- [ ] Git repo — silakan `git init && git add . && git commit -m "feat: flutter client"` lalu push ke GitHub Anda
