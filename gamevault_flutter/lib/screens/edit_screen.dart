import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/games_provider.dart';
import '../widgets/state_widgets.dart';

class EditScreen extends StatefulWidget {
  final Game? existing;
  const EditScreen({super.key, this.existing});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late final _title = TextEditingController(text: widget.existing?.title ?? '');
  late final _genre = TextEditingController(text: widget.existing?.genre ?? '');
  late final _platform = TextEditingController(text: widget.existing?.platform ?? '');
  late final _cover = TextEditingController(text: widget.existing?.coverUrl ?? '');
  late final _notes = TextEditingController(text: widget.existing?.notes ?? '');
  final _form = GlobalKey<FormState>();

  @override
  void dispose() {
    _title.dispose(); _genre.dispose(); _platform.dispose(); _cover.dispose(); _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final g = context.read<GamesProvider>();
    final e = widget.existing;
    final ok = e == null
        ? await g.create(
            title: _title.text.trim(), genre: _genre.text.trim(), platform: _platform.text.trim(),
            coverUrl: _cover.text.trim().isEmpty ? null : _cover.text.trim(),
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          )
        : await g.update(e.id,
            title: _title.text.trim(), genre: _genre.text.trim(), platform: _platform.text.trim(),
            coverUrl: _cover.text.trim().isEmpty ? null : _cover.text.trim(),
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          );
    if (ok && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final g = context.watch<GamesProvider>();
    final loading = g.mutationState is Loading;
    final err = g.mutationState is Failure<void> ? (g.mutationState as Failure<void>).message : null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.existing == null ? 'Tambah Game' : 'Ubah Game',
            style: const TextStyle(color: Colors.white)),
      ),
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _F('Judul', _title, required: true),
                  _F('Genre', _genre, required: true),
                  _F('Platform', _platform, required: true),
                  _F('Cover URL (opsional)', _cover),
                  _F('Catatan (opsional)', _notes, multiline: true),
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
                        : const Text('Simpan', style: TextStyle(fontWeight: FontWeight.w600)),
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

class _F extends StatelessWidget {
  final String label; final TextEditingController c; final bool required; final bool multiline;
  const _F(this.label, this.c, {this.required = false, this.multiline = false});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: c,
        maxLines: multiline ? 4 : 1,
        validator: required ? (v) => (v == null || v.trim().isEmpty) ? '$label wajib diisi' : null : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
