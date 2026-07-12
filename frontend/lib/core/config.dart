/// Configuración de entorno. Los valores se inyectan en tiempo de compilación con
/// `--dart-define` (o toman los valores por defecto para desarrollo local).
class AppConfig {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const scoresBucket = String.fromEnvironment(
    'SUPABASE_STORAGE_BUCKET',
    defaultValue: 'scores',
  );

  /// Si no hay credenciales de Supabase, la app corre en modo demostración
  /// (sin auth real). Útil para desarrollo de UI antes de provisionar Supabase.
  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
