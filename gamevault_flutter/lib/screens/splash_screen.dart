import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/page_route.dart';
import '../widgets/state_widgets.dart';
import 'library_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this, duration: const Duration(seconds: 3),
  )..repeat();

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final auth = context.read<AuthProvider>();
    await auth.bootstrap();
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    final next = (auth.mode == SessionMode.authenticated || auth.mode == SessionMode.guest)
        ? const LibraryScreen()
        : const LoginScreen();
    Navigator.of(context).pushReplacement(fadeSlideRoute(next));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) {
                  final t = Curves.easeInOut.transform((_ctrl.value * 2 % 1).abs());
                  final scale = 0.95 + t * 0.1;
                  return Transform.rotate(
                    angle: _ctrl.value * 6.283 / 5,
                    child: Transform.scale(
                      scale: scale,
                      child: const Icon(Icons.videogame_asset, size: 96, color: Color(0xFFA78BFA)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text('GameVault',
                  style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Koleksi gamemu, dalam satu tempat.',
                  style: TextStyle(color: Colors.white.withOpacity(.6), fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}
