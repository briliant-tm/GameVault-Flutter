import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/games_provider.dart';
import 'screens/splash_screen.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/games_service.dart';
import 'services/guest_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Configure system UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  
  // Configure image cache for better performance
  imageCache.maximumSize = 100;
  imageCache.maximumSizeBytes = 100 * 1024 * 1024; // 100MB

  final api = await ApiClient.create();
  final guest = await GuestStore.create();
  final authService = AuthService(api);
  final gamesService = GamesService(api);

  runApp(GameVaultApp(
    authService: authService, gamesService: gamesService, guest: guest,
  ));
}

class GameVaultApp extends StatelessWidget {
  final AuthService authService;
  final GamesService gamesService;
  final GuestStore guest;

  const GameVaultApp({
    super.key,
    required this.authService, required this.gamesService, required this.guest,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(auth: authService, guest: guest),
        ),
        ChangeNotifierProxyProvider<AuthProvider, GamesProvider>(
          create: (ctx) => GamesProvider(
            remote: gamesService, guest: guest,
            auth: ctx.read<AuthProvider>(),
          ),
          update: (_, auth, prev) => prev ?? GamesProvider(
            remote: gamesService, guest: guest, auth: auth,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'GameVault',
        debugShowCheckedModeBanner: false,
        theme: _theme(),
        scrollBehavior: const ScrollBehavior().copyWith(
          scrollbars: false,
          overscroll: true,
          physics: const BouncingScrollPhysics(),
        ),
        home: const SplashScreen(),
      ),
    );
  }

  ThemeData _theme() {
    final cs = ColorScheme.fromSeed(
      seedColor: const Color(0xFF8B5CF6),
      brightness: Brightness.dark,
      surface: const Color(0xFF1E1B36),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: const Color(0xFF0F0A1E),
      textTheme: const TextTheme().apply(bodyColor: Colors.white, displayColor: Colors.white),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: .7)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: .06),
      ),
    );
  }
}
