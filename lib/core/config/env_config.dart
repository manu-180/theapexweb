import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  // Constructor privado
  const EnvConfig._();

  static Future<void> load() async {
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      // Es normal no encontrar .env en producción o web, continuamos.
      debugPrint("Nota: Archivo .env no encontrado. Se usarán variables de entorno del sistema.");
    }
  }

  static String get supabaseUrl {
    return _get('SUPABASE_URL');
  }

  static String get supabaseAnonKey {
    return _get('SUPABASE_ANON_KEY');
  }

  static String _get(String key) {
    // 1. Prioridad: Dart Define (Compilación: --dart-define=KEY=VALUE)
    final fromDefine = String.fromEnvironment(key);
    if (fromDefine.isNotEmpty) return fromDefine;

    // 2. Prioridad: Archivo .env (Desarrollo local)
    return dotenv.env[key] ?? '';
  }
}