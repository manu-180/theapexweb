// Archivo: lib/main.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apex/app.dart';
import 'package:apex/core/config/theme/app_theme_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseUrlProvider = Provider<String>((ref) => throw UnimplementedError());

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Env (Estrategia Híbrida: Producción vs Local)
  // Intentamos cargar .env, pero si falla (ej: en Vercel/Producción), no rompemos la app.
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Nota: No se encontró archivo .env (Normal en Producción si usas Dart Define)");
  }

  // Helper para obtener variables con prioridad:
  // 1. Variables de compilación (--dart-define) -> Prioridad Producción
  // 2. Archivo .env -> Prioridad Desarrollo Local
  String getEnv(String key) {
    const fromDartDefine = String.fromEnvironment('SUPABASE_URL'); // Ejemplo de chequeo
    if (fromDartDefine.isNotEmpty && key == 'SUPABASE_URL') return const String.fromEnvironment('SUPABASE_URL');
    if (key == 'SUPABASE_ANON_KEY') {
       const keyDefine = String.fromEnvironment('SUPABASE_ANON_KEY');
       if (keyDefine.isNotEmpty) return keyDefine;
    }
    
    return dotenv.env[key] ?? '';
  }

  // 2. Initialize SharedPrefs
  final prefs = await SharedPreferences.getInstance();

  // 3. Initialize Supabase
  // Usamos el helper para evitar crashes por nulos
  final supabaseUrl = getEnv('SUPABASE_URL');
  final supabaseKey = getEnv('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    // Failsafe visual para desarrolladores
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text("Error Crítico: Faltan variables de entorno (SUPABASE_URL / ANON_KEY)"),
          ),
        ),
      ),
    );
    return;
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        supabaseUrlProvider.overrideWithValue(supabaseUrl),
      ],
      child: const App(),
    ),
  );
}