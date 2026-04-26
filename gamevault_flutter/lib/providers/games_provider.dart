import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../services/games_service.dart';
import '../services/guest_store.dart';
import 'auth_provider.dart';

class GamesProvider extends ChangeNotifier {
  GamesProvider({
    required GamesService remote,
    required GuestStore guest,
    required AuthProvider auth,
  })  : _remote = remote,
        _guest = guest,
        _auth = auth;

  final GamesService _remote;
  final GuestStore _guest;
  final AuthProvider _auth;

  UiState<List<Game>> _listState = const Idle();
  UiState<List<Game>> get listState => _listState;

  UiState<Game> _detailState = const Idle();
  UiState<Game> get detailState => _detailState;

  UiState<void> _mutationState = const Idle();
  UiState<void> get mutationState => _mutationState;

  String _search = '';
  String _genre = '';
  String _platform = '';
  String get search => _search;
  String get genre => _genre;
  String get platform => _platform;

  Timer? _debounce;

  void setSearch(String v) {
    _search = v;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), load);
    notifyListeners();
  }

  void setGenre(String v) { _genre = v; notifyListeners(); load(); }
  void setPlatform(String v) { _platform = v; notifyListeners(); load(); }

  Future<void> load() async {
    _listState = const Loading();
    notifyListeners();
    try {
      final data = _auth.isGuest
          ? await _guest.list(search: _search, genre: _genre, platform: _platform)
          : await _remote.list(search: _search, genre: _genre, platform: _platform);
      _listState = Success(data);
    } catch (e) {
      _listState = Failure(e.toString());
    }
    notifyListeners();
  }

  Future<void> loadDetail(int id) async {
    _detailState = const Loading();
    notifyListeners();
    try {
      final g = _auth.isGuest ? await _guest.get(id) : await _remote.get(id);
      _detailState = Success(g);
    } catch (e) {
      _detailState = Failure(e.toString());
    }
    notifyListeners();
  }

  Future<bool> create({
    required String title,
    required String genre,
    required String platform,
    String? coverUrl,
    String? notes,
  }) async {
    _mutationState = const Loading();
    notifyListeners();
    try {
      if (_auth.isGuest) {
        await _guest.createGame(title: title, genre: genre, platform: platform, coverUrl: coverUrl, notes: notes);
      } else {
        await _remote.create(title: title, genre: genre, platform: platform, coverUrl: coverUrl, notes: notes);
      }
      _mutationState = const Success(null);
      await load();
      return true;
    } catch (e) {
      _mutationState = Failure(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> update(int id, {
    required String title,
    required String genre,
    required String platform,
    String? coverUrl,
    String? notes,
  }) async {
    _mutationState = const Loading();
    notifyListeners();
    try {
      if (_auth.isGuest) {
        await _guest.update(id, title: title, genre: genre, platform: platform, coverUrl: coverUrl, notes: notes);
      } else {
        await _remote.update(id, title: title, genre: genre, platform: platform, coverUrl: coverUrl, notes: notes);
      }
      _mutationState = const Success(null);
      await load();
      return true;
    } catch (e) {
      _mutationState = Failure(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(int id) async {
    _mutationState = const Loading();
    notifyListeners();
    try {
      if (_auth.isGuest) {
        await _guest.delete(id);
      } else {
        await _remote.delete(id);
      }
      _mutationState = const Success(null);
      await load();
      return true;
    } catch (e) {
      _mutationState = Failure(e.toString());
      notifyListeners();
      return false;
    }
  }

  void clearMutation() {
    _mutationState = const Idle();
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
