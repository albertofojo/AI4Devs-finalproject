import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Visor de partituras (TK-10). Renderiza MusicXML con OpenSheetMusicDisplay
/// embebiendo la página `web/osmd.html` en un iframe. Para PDF, muestra el
/// fichero directamente. Es la funcionalidad diferenciadora del MVP.
class ScoreViewerScreen extends StatefulWidget {
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
  State<ScoreViewerScreen> createState() => _ScoreViewerScreenState();
}

class _ScoreViewerScreenState extends State<ScoreViewerScreen> {
  static final Set<String> _registered = {};
  late final String _viewType;

  @override
  void initState() {
    super.initState();
    _viewType = 'score-view-${widget.fileUrl.hashCode}-${widget.format}';
    if (!_registered.contains(_viewType)) {
      _registered.add(_viewType);
      ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _) {
        final iframe = web.HTMLIFrameElement()
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%';
        if (widget.format == 'pdf') {
          iframe.src = widget.fileUrl;
        } else {
          iframe.src = 'osmd.html?src=${Uri.encodeComponent(widget.fileUrl)}';
        }
        return iframe;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: widget.fileUrl.isEmpty
          ? const Center(child: Text('No hay fichero para mostrar.'))
          : HtmlElementView(viewType: _viewType),
    );
  }
}
