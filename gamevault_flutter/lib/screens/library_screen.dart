import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../providers/games_provider.dart';
import '../widgets/page_route.dart';
import '../widgets/state_widgets.dart';
import 'account_screen.dart';
import 'detail_screen.dart';
import 'edit_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});
  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GamesProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final games = context.watch<GamesProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('GameVault', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () => Navigator.of(context).push(fadeSlideRoute(const AccountScreen())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(fadeSlideRoute(const EditScreen())),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, a) => SizeTransition(
                  sizeFactor: a,
                  child: FadeTransition(opacity: a, child: child),
                ),
                child: auth.isGuest ? _GuestBanner(remaining: auth.guestRemaining) : const SizedBox.shrink(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: TextField(
                  onChanged: games.setSearch,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Cari judul game…',
                    filled: true, fillColor: Colors.white.withOpacity(.08),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(child: _Chip('Genre', games.genre, games.setGenre)),
                    const SizedBox(width: 8),
                    Expanded(child: _Chip('Platform', games.platform, games.setPlatform)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildBody(games),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(GamesProvider g) {
    final s = g.listState;
    if (s is Loading) return const LoadingView(label: 'Memuat koleksi…', key: ValueKey('loading'));
    if (s is Failure<List<Game>>) {
      return ErrorStateView(key: const ValueKey('error'), message: s.message, onRetry: g.load);
    }
    if (s is Success<List<Game>>) {
      final items = s.data;
      if (items.isEmpty) {
        return Center(
          key: const ValueKey('empty'),
          child: Text('Belum ada game. Tambah yang pertama!',
              style: TextStyle(color: Colors.white.withOpacity(.6))),
        );
      }
      return RefreshIndicator(
        onRefresh: g.load,
        child: GridView.builder(
          key: const ValueKey('grid'),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 220, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .72,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) => _GameCard(game: items[i]),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}

class _Chip extends StatelessWidget {
  final String label; final String value; final ValueChanged<String> onChanged;
  const _Chip(this.label, this.value, this.onChanged);
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: label,
        filled: true, fillColor: Colors.white.withOpacity(.06),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }
}

class _GuestBanner extends StatelessWidget {
  final Duration remaining;
  const _GuestBanner({required this.remaining});
  @override
  Widget build(BuildContext context) {
    final days = remaining.inDays;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF3D1A78),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text('Mode Guest aktif — data akan dihapus otomatis dalam $days hari.',
          style: const TextStyle(color: Colors.white, fontSize: 13)),
    );
  }
}

class _GameCard extends StatelessWidget {
  final Game game;
  const _GameCard({required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1E1B36),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(fadeSlideRoute(DetailScreen(id: game.id))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: 'game-${game.id}',
                child: (game.coverUrl != null && game.coverUrl!.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: game.coverUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => _Placeholder(letter: game.title),
                        placeholder: (_, __) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : _Placeholder(letter: game.title),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(game.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('${game.genre} · ${game.platform}',
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white.withOpacity(.6), fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String letter;
  const _Placeholder({required this.letter});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF3D1A78), Color(0xFF1A0D2E)]),
      ),
      child: Center(
        child: Text(letter.isEmpty ? '?' : letter[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
