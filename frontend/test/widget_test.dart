import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xanee_frontend/features/auth/auth_scaffold.dart';

void main() {
  testWidgets('El formulario de auth valida email y contraseña', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: AuthScaffold(
        title: 'Inicia sesión',
        submitLabel: 'Entrar',
        onSubmit: (_, __) async {},
        footer: const SizedBox.shrink(),
      ),
    ));

    // Enviar vacío → aparecen errores de validación.
    await tester.tap(find.byKey(const Key('submit_button')));
    await tester.pump();
    expect(find.text('Email no válido'), findsOneWidget);
    expect(find.text('Mínimo 6 caracteres'), findsOneWidget);

    // Rellenar correctamente → sin errores.
    await tester.enterText(find.byKey(const Key('email_field')), 'a@b.com');
    await tester.enterText(find.byKey(const Key('password_field')), 'secret1');
    await tester.tap(find.byKey(const Key('submit_button')));
    await tester.pump();
    expect(find.text('Email no válido'), findsNothing);
    expect(find.text('Mínimo 6 caracteres'), findsNothing);
  });
}
