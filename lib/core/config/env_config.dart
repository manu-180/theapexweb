import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  const EnvConfig._();

  static Future<void> load() async {
    // En Web en release no cargamos .env (no exponer credenciales). En debug sí para desarrollo local.
    if (kIsWeb && !kDebugMode) return;

    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint("Nota: .env no cargado (usa variables de entorno o --dart-define): $e");
    }
  }

  static String get supabaseUrl {
    const fromDefine = String.fromEnvironment('SUPABASE_URL');
    if (fromDefine.isNotEmpty) return fromDefine;
    if (kIsWeb && !kDebugMode) return '';
    try {
      return dotenv.env['SUPABASE_URL'] ?? '';
    } catch (_) {
      return '';
    }
  }

  static String get supabaseAnonKey {
    const fromDefine = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (fromDefine.isNotEmpty) return fromDefine;
    if (kIsWeb && !kDebugMode) return '';
    try {
      return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    } catch (_) {
      return '';
    }
  }
}