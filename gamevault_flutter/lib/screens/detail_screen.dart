import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/games_provider.dart';
import '../widgets/page_route.dart';
import '../widgets/state_widgets.dart';
import 'edit_screen.dart';

class DetailScreen extends StatefulWidget {
  final int id;
  const DetailScreen({super.key, required this.id});
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GamesProvider>().loadDetail(widget.id);
    });
  }

  Future<void> _confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus game?'),
        content: const Text('Aksi ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      final success = await context.read<GamesProvider>().delete(widget.id);
      if (success && mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final g = context.watch<GamesProvider>();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Detail Game', style: TextStyle(color: Colors.white)),
        actions: [
          if (g.detailState is Success<Game>)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () => Navigator.of(context).push(
                  fadeSlideRoute(EditScreen(existing: (g.detailState as Success<Game>).data))),
            ),
          IconButton(
            icon: const Icon(Icons.delete, color: Color(0xFFEF4444)),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: GradientBackground(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _body(g),
        ),
      ),
    );
  }

  Widget _body(GamesProvider g) {
    final s = g.detailState;
    if (s is Loading) return const LoadingView(key: ValueKey('loading'));
    if (s is Failure<Game>) {
      return ErrorStateView(
        key: const ValueKey('err'),
        message: s.message,
        onRetry: () => g.loadDetail(widget.id),
      );
    }
    if (s is Success<Game>) return _DetailBody(key: const ValueKey('ok'), game: s.data);
    return const SizedBox.shrink();
  }
}

class _DetailBody extends StatelessWidget {
  final Game game;
  const _DetailBody({super.key, required this.game});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'game-${game.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: (game.coverUrl != null && game.coverUrl!.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: game.coverUrl!,
                        height: 280, width: double.infinity, fit: BoxFit.cover,
                      )
                    : Container(
                        height: 200,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0xFF3D1A78), Color(0xFF1A0D2E)]),
                        ),
                        child: Center(
                          child: Text(game.title.isNotEmpty ? game.title[0].toUpperCase() : '?',
                              style: const TextStyle(color: Colors.white, fontSize: 64, fontWeight: FontWeight.bold)),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Text(game.title, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${game.genre} · ${game.platform}',
                style: const TextStyle(color: Color(0xFFA78BFA), fontSize: 14)),
            const SizedBox(height: 20),
            if (game.notes != null && game.notes!.isNotEmpty) ...[
              const Text('Catatan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(game.notes!, style: const TextStyle(color: Color(0xFFCBD5E1))),
            ],
          ],
        ),
      ),
    );
  }
}
