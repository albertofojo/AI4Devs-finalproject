import 'package:flutter/material.dart';

/// Implementación no-web (usada por el tester VM). El visor real es Web-only;
/// aquí mostramos un marcador informativo.
Widget buildScoreView({required String fileUrl, required String format}) {
  return const Center(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Text(
        'El visor de partituras está disponible en la versión Web.',
        textAlign: TextAlign.center,
      ),
    ),
  );
}
