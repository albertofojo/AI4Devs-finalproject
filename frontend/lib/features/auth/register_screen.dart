import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';
import 'auth_scaffold.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Crea tu cuenta',
      submitLabel: 'Registrarme',
      onSubmit: (email, password) =>
          context.read<AuthService>().signUp(email, password),
      footer: TextButton(
        onPressed: () => context.go('/login'),
        child: const Text('¿Ya tienes cuenta? Inicia sesión'),
      ),
    );
  }
}
