import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config.dart';
import '../../core/repository.dart';

/// Diálogo de subida de partitura. Sube el fichero a Supabase Storage (si está
/// configurado) y persiste los metadatos en el backend. Si no hay Supabase,
/// permite pegar una URL pública a la partitura (MusicXML/PDF).
class UploadScoreDialog extends StatefulWidget {
  const UploadScoreDialog({super.key, required this.groupId});
  final String groupId;

  @override
  State<UploadScoreDialog> createState() => _UploadScoreDialogState();
}

class _UploadScoreDialogState extends State<UploadScoreDialog> {
  final _title = TextEditingController();
  final _composer = TextEditingController();
  final _key = TextEditingController();
  final _url = TextEditingController();
  String _format = 'musicxml';
  String? _fileName;
  bool _saving = false;
  String? _error;

  DataRepository get _repo => context.read<DataRepository>();

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['musicxml', 'xml', 'mxl', 'pdf'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final ext = (file.extension ?? '').toLowerCase();
    setState(() {
      _fileName = file.name;
      _format = ext == 'pdf' ? 'pdf' : 'musicxml';
      if (_title.text.trim().isEmpty) {
        _title.text = file.name.replaceAll(RegExp(r'\.[^.]+$'), '');
      }
    });

    if (!AppConfig.hasSupabase) {
      setState(() => _error =
          'Sin Supabase configurado: pega una URL pública a la partitura.');
      return;
    }
    if (file.bytes == null) {
      setState(() => _error = 'No se pudo leer el fichero.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final client = Supabase.instance.client;
      final path =
          '${widget.groupId}/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      await client.storage.from(AppConfig.scoresBucket).uploadBinary(
            path,
            file.bytes!,
            fileOptions: const FileOptions(upsert: true),
          );
      _url.text = client.storage.from(AppConfig.scoresBucket).getPublicUrl(path);
    } catch (e) {
      _error = 'Error subiendo a Storage: $e';
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _url.text.trim().isEmpty) {
      setState(() => _error = 'Título y fichero/URL son obligatorios');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _repo.createScore(
        widget.groupId,
        title: _title.text.trim(),
        format: _format,
        fileUrl: _url.text.trim(),
        composer: _composer.text.trim(),
        keySignature: _key.text.trim(),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _error = '$e';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Subir partitura'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                onPressed: _saving ? null : _pickAndUpload,
                icon: const Icon(Icons.attach_file),
                label: Text(_fileName ?? 'Seleccionar archivo (MusicXML/PDF)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _title,
                key: const Key('score_title_field'),
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _composer,
                decoration: const InputDecoration(labelText: 'Compositor (opcional)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _key,
                decoration: const InputDecoration(labelText: 'Tonalidad (opcional)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _url,
                key: const Key('score_url_field'),
                decoration: const InputDecoration(
                  labelText: 'URL del fichero',
                  helperText: 'Se rellena al subir, o pégala manualmente',
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _format,
                decoration: const InputDecoration(labelText: 'Formato'),
                items: const [
                  DropdownMenuItem(value: 'musicxml', child: Text('MusicXML')),
                  DropdownMenuItem(value: 'pdf', child: Text('PDF')),
                ],
                onChanged: (v) => setState(() => _format = v ?? 'musicxml'),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        FilledButton(
          key: const Key('score_save_button'),
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Guardar'),
        ),
      ],
    );
  }
}
