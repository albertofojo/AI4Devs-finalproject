import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';
import 'auth_scaffold.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Inicia sesión',
      submitLabel: 'Entrar',
      onSubmit: (email, password) =>
          context.read<AuthService>().signIn(email, password),
      footer: TextButton(
        onPressed: () => context.go('/register'),
        child: const Text('¿No tienes cuenta? Regístrate'),
      ),
    );
  }
}
