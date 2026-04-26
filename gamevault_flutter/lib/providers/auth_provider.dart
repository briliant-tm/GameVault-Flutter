import 'package:flutter/foundation.dart';
import 'dart:async';

import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/guest_store.dart';

enum SessionMode { unknown, unauthenticated, authenticated, guest }

class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthService auth, required GuestStore guest})
      : _auth = auth,
        _guest = guest;

  final AuthService _auth;
  final GuestStore _guest;

  SessionMode _mode = SessionMode.unknown;
  User? _user;
  UiState<void> _action = const Idle();

  SessionMode get mode => _mode;
  User? get user => _user;
  UiState<void> get action => _action;
  bool get isGuest => _mode == SessionMode.guest;
  bool get isAuthed => _mode == SessionMode.authenticated;
  Duration get guestRemaining => _guest.remaining;
  String get guestNickname => _guest.nickname;

  Future<void> bootstrap() async {
    try {
      await _guest.cleanupIfExpired();
      if (_guest.isGuest) {
        _mode = SessionMode.guest;
        notifyListeners();
        return;
      }
      
      try {
        final u = await _auth.me().timeout(
          const Duration(seconds: 8),
          onTimeout: () => throw TimeoutException('Koneksi timeout'),
        );
        if (u != null) {
          _user = u;
          _mode = SessionMode.authenticated;
        } else {
          _mode = SessionMode.unauthenticated;
        }
      } catch (e) {
        // Jika API error/timeout, anggap unauthenticated
        _mode = SessionMode.unauthenticated;
      }
      notifyListeners();
    } catch (e) {
      _mode = SessionMode.unauthenticated;
      notifyListeners();
    }
  }

  Future<bool> login(String identifier, String password) async {
    _action = const Loading();
    notifyListeners();
    try {
      _user = await _auth.login(identifier, password);
      _mode = SessionMode.authenticated;
      _action = const Success(null);
      notifyListeners();
      return true;
    } catch (e) {
      _action = Failure(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? nickname,
  }) async {
    _action = const Loading();
    notifyListeners();
    try {
      _user = await _auth.register(
        username: username, email: email, password: password, nickname: nickname,
      );
      _mode = SessionMode.authenticated;
      _action = const Success(null);
      notifyListeners();
      return true;
    } catch (e) {
      _action = Failure(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<void> enterGuest() async {
    await _guest.startGuest();
    _mode = SessionMode.guest;
    _user = null;
    notifyListeners();
  }

  Future<void> logout() async {
    await _auth.logout();
    await _guest.endGuest();
    _user = null;
    _mode = SessionMode.unauthenticated;
    notifyListeners();
  }

  Future<bool> updateAccount({String? nickname, String? currentPassword, String? newPassword}) async {
    _action = const Loading();
    notifyListeners();
    try {
      _user = await _auth.updateAccount(
        nickname: nickname, currentPassword: currentPassword, newPassword: newPassword,
      );
      _action = const Success(null);
      notifyListeners();
      return true;
    } catch (e) {
      _action = Failure(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAccount(String password) async {
    _action = const Loading();
    notifyListeners();
    try {
      await _auth.deleteAccount(password);
      _user = null;
      _mode = SessionMode.unauthenticated;
      _action = const Success(null);
      notifyListeners();
      return true;
    } catch (e) {
      _action = Failure(e.toString());
      notifyListeners();
      return false;
    }
  }

  void clearAction() {
    _action = const Idle();
    notifyListeners();
  }
}
