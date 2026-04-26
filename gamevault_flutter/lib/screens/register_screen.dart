import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/auth_provider.dart';
import '../widgets/page_route.dart';
import '../widgets/state_widgets.dart';
import 'library_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _nickname = TextEditingController();
  final _form = GlobalKey<FormState>();

  @override
  void dispose() {
    _username.dispose(); _email.dispose(); _password.dispose(); _nickname.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.register(
      username: _username.text.trim(),
      email: _email.text.trim(),
      password: _password.text,
      nickname: _nickname.text.trim(),
    );
    if (ok && mounted) {
      Navigator.of(context).pushAndRemoveUntil(fadeSlideRoute(const LibraryScreen()), (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loading = auth.action is Loading;
    final err = auth.action is Failure<void> ? (auth.action as Failure<void>).message : null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Daftar Akun'),
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Field(controller: _username, label: 'Username',
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib' : null),
                  const SizedBox(height: 12),
                  _Field(controller: _email, label: 'Email',
                      validator: (v) => (v == null || !v.contains('@')) ? 'Email tidak valid' : null),
                  const SizedBox(height: 12),
                  _Field(controller: _nickname, label: 'Nickname (opsional)'),
                  const SizedBox(height: 12),
                  _Field(controller: _password, label: 'Password (≥6 karakter)', obscure: true,
                      validator: (v) => (v == null || v.length < 6) ? 'Minimal 6 karakter' : null),
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
                        : const Text('Daftar', style: TextStyle(fontWeight: FontWeight.w600)),
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
