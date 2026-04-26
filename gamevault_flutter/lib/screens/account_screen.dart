import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../widgets/page_route.dart';
import '../widgets/state_widgets.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});
  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _nickname = TextEditingController();
  final _curPw = TextEditingController();
  final _newPw = TextEditingController();

  @override
  void dispose() {
    _nickname.dispose(); _curPw.dispose(); _newPw.dispose(); super.dispose();
  }

  Future<void> _confirmDelete() async {
    final pwController = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus akun permanen?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Masukkan password untuk konfirmasi.'),
            const SizedBox(height: 8),
            TextField(controller: pwController, obscureText: true,
                decoration: const InputDecoration(labelText: 'Password')),
          ],
        ),
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
      final success = await context.read<AuthProvider>().deleteAccount(pwController.text);
      if (success && mounted) {
        Navigator.of(context).pushAndRemoveUntil(fadeSlideRoute(const LoginScreen()), (_) => false);
      }
    }
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(fadeSlideRoute(const LoginScreen()), (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Akun', style: TextStyle(color: Colors.white)),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (auth.isAuthed && auth.user != null) _AuthedView(
                  user: auth.user!,
                  nickname: _nickname, curPw: _curPw, newPw: _newPw,
                  onSave: () async {
                    await auth.updateAccount(
                      nickname: _nickname.text.trim().isEmpty ? null : _nickname.text.trim(),
                      currentPassword: _curPw.text.isEmpty ? null : _curPw.text,
                      newPassword: _newPw.text.isEmpty ? null : _newPw.text,
                    );
                    if (mounted && auth.action is Success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profil tersimpan')),
                      );
                    }
                  },
                  onDelete: _confirmDelete,
                  state: auth.action,
                ),
                if (auth.isGuest) _GuestView(
                  remaining: auth.guestRemaining,
                  onRegister: () => Navigator.of(context).push(fadeSlideRoute(const RegisterScreen())),
                ),
                const SizedBox(height: 32),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  onPressed: _logout,
                  child: const Text('Keluar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthedView extends StatelessWidget {
  final User user;
  final TextEditingController nickname;
  final TextEditingController curPw;
  final TextEditingController newPw;
  final VoidCallback onSave;
  final VoidCallback onDelete;
  final UiState<void> state;
  const _AuthedView({
    required this.user,
    required this.nickname, required this.curPw, required this.newPw,
    required this.onSave, required this.onDelete, required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final loading = state is Loading;
    final err = state is Failure<void> ? (state as Failure<void>).message : null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(user.nickname ?? user.username,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(user.email, style: TextStyle(color: Colors.white.withOpacity(.6))),
        const SizedBox(height: 24),
        const Text('Ubah profil',
            style: TextStyle(color: Color(0xFFA78BFA), fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        _Field('Nickname baru', nickname),
        _Field('Password saat ini', curPw, obscure: true),
        _Field('Password baru (opsional)', newPw, obscure: true),
        if (err != null) Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(err, style: const TextStyle(color: Color(0xFFEF4444))),
        ),
        const SizedBox(height: 12),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          onPressed: loading ? null : onSave,
          child: Text(loading ? 'Menyimpan…' : 'Simpan perubahan'),
        ),
        const SizedBox(height: 24),
        const Text('Zona Berbahaya',
            style: TextStyle(color: Color(0xFFA78BFA), fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            foregroundColor: const Color(0xFFEF4444),
            side: const BorderSide(color: Color(0xFFEF4444)),
          ),
          onPressed: onDelete,
          child: const Text('Hapus akun'),
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final String label; final TextEditingController c; final bool obscure;
  const _Field(this.label, this.c, {this.obscure = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: c,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _GuestView extends StatelessWidget {
  final Duration remaining;
  final VoidCallback onRegister;
  const _GuestView({required this.remaining, required this.onRegister});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Mode Guest',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        Text('Data lokal akan dihapus otomatis dalam ${remaining.inDays} hari.',
            style: TextStyle(color: Colors.white.withOpacity(.6))),
        const SizedBox(height: 16),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
          onPressed: onRegister,
          child: const Text('Daftar agar data tidak terhapus'),
        ),
      ],
    );
  }
}
