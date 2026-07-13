import 'dart:convert';

import 'package:http/http.dart' as http;

import '../features/auth/auth_service.dart';
import 'config.dart';

/// Error del API con código HTTP y mensaje legible.
class ApiException implements Exception {
  ApiException(this.statusCode, this.message);
  final int statusCode;
  final String message;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

/// Cliente HTTP fino sobre el backend FastAPI. Adjunta el JWT de Supabase en cada
/// petición y normaliza el manejo de errores.
class ApiClient {
  ApiClient(this._auth);

  final AuthService _auth;
  final http.Client _http = http.Client();

  Uri _uri(String path) => Uri.parse('${AppConfig.apiBaseUrl}$path');

  Map<String, String> get _headers {
    final token = _auth.accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  dynamic _decode(http.Response res) {
    final body = res.body.isEmpty ? null : jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    final detail = (body is Map && body['detail'] != null)
        ? body['detail'].toString()
        : 'Error inesperado';
    throw ApiException(res.statusCode, detail);
  }

  Future<dynamic> get(String path) async {
    final res = await _http.get(_uri(path), headers: _headers);
    return _decode(res);
  }

  Future<dynamic> post(String path, [Map<String, dynamic>? body]) async {
    final res = await _http.post(
      _uri(path),
      headers: _headers,
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(res);
  }

  Future<dynamic> put(String path, [Map<String, dynamic>? body]) async {
    final res = await _http.put(
      _uri(path),
      headers: _headers,
      body: body == null ? null : jsonEncode(body),
    );
    return _decode(res);
  }
}
