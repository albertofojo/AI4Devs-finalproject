import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config.dart';

/// Estado de autenticación de la app. Envuelve Supabase Auth y expone el token
/// de acceso (JWT) que el backend verifica. Si no hay Supabase configurado,
/// funciona en un modo demostración local (sin token válido para el backend).
class AuthService extends ChangeNotifier {
  AuthService() {
    if (AppConfig.hasSupabase) {
      _sub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
        notifyListeners();
      });
    }
  }

  Object? _sub;

  bool _demoSignedIn = false;
  String? _demoEmail;

  bool get isAuthenticated {
    if (AppConfig.hasSupabase) {
      return Supabase.instance.client.auth.currentSession != null;
    }
    return _demoSignedIn;
  }

  String? get accessToken {
    if (AppConfig.hasSupabase) {
      return Supabase.instance.client.auth.currentSession?.accessToken;
    }
    return _demoSignedIn ? 'demo-token' : null;
  }

  String? get email {
    if (AppConfig.hasSupabase) {
      return Supabase.instance.client.auth.currentUser?.email;
    }
    return _demoEmail;
  }

  Future<void> signIn(String email, String password) async {
    if (!AppConfig.hasSupabase) {
      _demoSignedIn = true;
      _demoEmail = email;
      notifyListeners();
      return;
    }
    await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    if (!AppConfig.hasSupabase) {
      _demoSignedIn = true;
      _demoEmail = email;
      notifyListeners();
      return;
    }
    final res = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
    // Si la confirmación por email está desactivada, quedamos con sesión activa.
    if (res.session == null) {
      // Requiere confirmación: intentamos iniciar sesión igualmente.
      await signIn(email, password);
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    if (!AppConfig.hasSupabase) {
      _demoSignedIn = false;
      _demoEmail = null;
      notifyListeners();
      return;
    }
    await Supabase.instance.client.auth.signOut();
    notifyListeners();
  }

  @override
  void dispose() {
    final sub = _sub;
    if (sub is StreamSubscription) sub.cancel();
    super.dispose();
  }
}
