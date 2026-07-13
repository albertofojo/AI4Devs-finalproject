import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

final Set<String> _registered = {};

/// Implementación Web del visor: embebe un iframe. Para MusicXML apunta a la
/// página `web/osmd.html` (OpenSheetMusicDisplay); para PDF, al fichero directo.
Widget buildScoreView({required String fileUrl, required String format}) {
  if (fileUrl.isEmpty) {
    return const Center(child: Text('No hay fichero para mostrar.'));
  }
  final viewType = 'score-view-${fileUrl.hashCode}-$format';
  if (!_registered.contains(viewType)) {
    _registered.add(viewType);
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int _) {
      final iframe = web.HTMLIFrameElement()
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
      iframe.src = format == 'pdf'
          ? fileUrl
          : 'osmd.html?src=${Uri.encodeComponent(fileUrl)}';
      return iframe;
    });
  }
  return HtmlElementView(viewType: viewType);
}
