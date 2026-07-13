import 'package:flutter/material.dart';

// Selección de plataforma: implementación Web (iframe + OSMD) o stub (VM/tests).
import 'score_view_platform_stub.dart'
    if (dart.library.js_interop) 'score_view_platform_web.dart';

/// Visor de partituras (TK-10). Renderiza MusicXML con OpenSheetMusicDisplay en
/// Web; en otras plataformas muestra un marcador. Funcionalidad diferenciadora
/// del MVP: abrir la partitura del setlist sin salir de la app.
class ScoreViewerScreen extends StatelessWidget {
  const ScoreViewerScreen({
    super.key,
    required this.title,
    required this.fileUrl,
    required this.format,
  });

  final String title;
  final String fileUrl;
  final String format;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: buildScoreView(fileUrl: fileUrl, format: format),
    );
  }
}
