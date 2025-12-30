// Archivo: lib/main.dart
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apex/app.dart';
import 'package:apex/core/config/theme/app_theme_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// Importación condicional para usar APIs web solo donde corresponde
import 'package:web/web.dart' as web; 

final supabaseUrlProvider = Provider<String>((ref) => throw UnimplementedError());

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Env
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Nota: .env no encontrado (OK en Producción)");
  }

  String getEnv(String key) {
    const fromDartDefine = String.fromEnvironment('SUPABASE_URL');
    if (fromDartDefine.isNotEmpty && key == 'SUPABASE_URL') return fromDartDefine;
    if (key == 'SUPABASE_ANON_KEY') {
       const keyDefine = String.fromEnvironment('SUPABASE_ANON_KEY');
       if (keyDefine.isNotEmpty) return keyDefine;
    }
    return dotenv.env[key] ?? '';
  }

  // 2. Prefs
  final prefs = await SharedPreferences.getInstance();

  // 3. Supabase con Fallback de Red
  final supabaseUrl = getEnv('SUPABASE_URL');
  final supabaseKey = getEnv('SUPABASE_ANON_KEY');

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    runApp(const _CriticalErrorApp(message: "Faltan variables de entorno"));
    return;
  }

  try {
    // Timeout para no dejar al usuario esperando eternamente si la red cuelga
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseKey,
    ).timeout(const Duration(seconds: 10));

    // Si todo va bien, arrancamos la App normal
    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          supabaseUrlProvider.overrideWithValue(supabaseUrl),
        ],
        child: const App(),
      ),
    );

  } catch (e) {
    // Si falla la conexión inicial (DNS, Offline), mostramos la pantalla de Reintento
    debugPrint("Error inicializando Supabase: $e");
    runApp(_NetworkErrorApp(
      onRetry: () {
        if (kIsWeb) {
          // EN WEB: Recarga real del navegador para limpiar memoria y estado
          web.window.location.reload();
        } else {
          // EN MÓVIL: Reintentamos la inicialización
          main();
        }
      }
    ));
  }
}

// Pantalla bonita para errores de Configuración
class _CriticalErrorApp extends StatelessWidget {
  final String message;
  const _CriticalErrorApp({required this.message});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(child: Text("Error Crítico: $message")),
      ),
    );
  }
}

// Pantalla bonita para errores de Red (Offline al inicio)
class _NetworkErrorApp extends StatelessWidget {
  final VoidCallback onRetry;
  const _NetworkErrorApp({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), // Tema oscuro por defecto para error
      home: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 64, color: Colors.redAccent),
                const SizedBox(height: 24),
                const Text(
                  "No pudimos conectar con el servidor",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  "Verifica tu conexión a internet para cargar el portfolio.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Reintentar"),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}