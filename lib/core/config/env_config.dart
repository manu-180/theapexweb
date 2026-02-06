import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  const EnvConfig._();

  static Future<void> load() async {
    // En Web no cargamos .env: evita 404 a assets/.env en producción.
    // Usar --dart-define=SUPABASE_URL=... y SUPABASE_ANON_KEY=... en el build.
    if (kIsWeb) return;

    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      debugPrint("Nota: .env no cargado (Uso de variables de entorno o defaults): $e");
    }
  }

  static String get supabaseUrl {
    // CORRECCIÓN: Usamos String.fromEnvironment con el literal directo y const
    const fromDefine = String.fromEnvironment('SUPABASE_URL');
    if (fromDefine.isNotEmpty) return fromDefine;
    
    return dotenv.env['SUPABASE_URL'] ?? '';
  }

  static String get supabaseAnonKey {
    // CORRECCIÓN: Usamos String.fromEnvironment con el literal directo y const
    const fromDefine = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (fromDefine.isNotEmpty) return fromDefine;

    return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }
}