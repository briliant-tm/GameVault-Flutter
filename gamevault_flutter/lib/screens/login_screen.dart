import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../widgets/page_route.dart';
import '../widgets/state_widgets.dart';
import 'library_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _id = TextEditingController();
  final _pw = TextEditingController();
  final _form = GlobalKey<FormState>();

  @override
  void dispose() { _id.dispose(); _pw.dispose(); super.dispose(); }

  void _goLibrary() {
    Navigator.of(context).pushReplacement(fadeSlideRoute(const LibraryScreen()));
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(_id.text.trim(), _pw.text);
    if (ok && mounted) _goLibrary();
  }

  Future<void> _asGuest() async {
    final auth = context.read<AuthProvider>();
    await auth.enterGuest();
    if (mounted) _goLibrary();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loading = auth.action is Loading;
    final err = auth.action is Failure<void> ? (auth.action as Failure<void>).message : null;

    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  const Icon(Icons.videogame_asset, size: 72, color: Color(0xFFA78BFA)),
                  const SizedBox(height: 12),
                  const Text('Selamat Datang',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  Text('Masuk ke GameVault kamu',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withOpacity(.6))),
                  const SizedBox(height: 28),
                  _Field(controller: _id, label: 'Username atau Email',
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null),
                  const SizedBox(height: 12),
                  _Field(controller: _pw, label: 'Password', obscure: true,
                      validator: (v) => (v == null || v.isEmpty) ? 'Wajib diisi' : null),
                  if (err != null) Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(err, style: const TextStyle(color: Color(0xFFEF4444))),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                    onPressed: loading ? null : _submit,
                    child: loading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Masuk', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                    onPressed: loading ? null : _asGuest,
                    child: const Text('Masuk sebagai Guest'),
                  ),
                  const SizedBox(height: 12),
                  Text('Mode Guest menyimpan data lokal saja, dan akan terhapus otomatis dalam 14 hari.',
                      style: TextStyle(color: Colors.white.withOpacity(.5), fontSize: 12)),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(fadeSlideRoute(const RegisterScreen())),
                    child: const Text('Belum punya akun? Daftar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final String? Function(String?)? validator;
  const _Field({required this.controller, required this.label, this.obscure = false, this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
