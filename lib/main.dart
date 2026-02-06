import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apex/app.dart';
import 'package:apex/core/config/theme/app_theme_providers.dart';
import 'package:apex/core/config/env_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider global para la URL
final supabaseUrlProvider = Provider<String>((ref) => EnvConfig.supabaseUrl);

// Fallback: SharedPreferences en memoria (no persiste, solo para que la app funcione)
class _InMemorySharedPreferences implements SharedPreferences {
  final Map<String, Object> _data = {};

  @override
  Future<bool> clear() async {
    _data.clear();
    return true;
  }

  @override
  Future<bool> commit() async => true;

  @override
  bool containsKey(String key) => _data.containsKey(key);

  @override
  Object? get(String key) => _data[key];

  @override
  bool? getBool(String key) => _data[key] as bool?;

  @override
  double? getDouble(String key) => _data[key] as double?;

  @override
  int? getInt(String key) => _data[key] as int?;

  @override
  Set<String> getKeys() => _data.keys.toSet();

  @override
  String? getString(String key) => _data[key] as String?;

  @override
  List<String>? getStringList(String key) => (_data[key] as List?)?.cast<String>();

  @override
  Future<void> reload() async {}

  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setDouble(String key, double value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _data[key] = value;
    return true;
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _BootstrapApp());
}

class _BootstrapApp extends StatefulWidget {
  const _BootstrapApp();

  @override
  State<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<_BootstrapApp> {
  late Future<SharedPreferences> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeApp();
  }

  Future<SharedPreferences> _initializeApp() async {
    // 1. Carga de Entorno (Silenciosa si falla)
    await EnvConfig.load();

    // 2. Preferencias (Esto es lo único vital para que Riverpod no falle)
    SharedPreferences prefs;
    try {
      prefs = await SharedPreferences.getInstance();
    } catch (e, stack) {
      debugPrint('⚠️ Error al cargar SharedPreferences (localStorage): $e');
      if (kDebugMode) debugPrint('$stack');
      debugPrint('📦 Usando almacenamiento en memoria como fallback (ajustes no se guardarán)');
      // En Flutter Web, SharedPreferences usa localStorage.
      // Si falla (ej: navegador en modo privado, políticas de seguridad, Vercel),
      // usamos un fallback en memoria para que la app funcione de todos modos.
      prefs = _InMemorySharedPreferences();
    }

    // 3. Validación y Supabase (Intento optimista)
    final url = EnvConfig.supabaseUrl;
    final key = EnvConfig.supabaseAnonKey;

    if (url.isNotEmpty && key.isNotEmpty) {
      try {
        // Intentamos conectar, pero si falla, NO detenemos la app.
        await Supabase.initialize(
          url: url,
          anonKey: key,
          // En Web, deshabilitamos la reconexión automática de Realtime
          // para evitar errores de autenticación WebSocket en el navegador
          realtimeClientOptions: RealtimeClientOptions(
            eventsPerSecond: 10,
            // En Web, reducimos el nivel de log de errores
            logLevel: kIsWeb ? RealtimeLogLevel.error : RealtimeLogLevel.info,
          ),
          // Para Flutter Web: PKCE y detección de sesión en la URL (OAuth callback)
          authOptions: const FlutterAuthClientOptions(
            authFlowType: AuthFlowType.pkce,
            detectSessionInUri: true,
          ),
        ).timeout(const Duration(seconds: 10)); // Timeout más largo para Web

        // En Web: si la URL trae ?code=... (vuelta de Google OAuth), intercambiamos
        // el code por sesión aquí para que la foto y el usuario estén listos al pintar la UI.
        if (kIsWeb && Uri.base.queryParameters.containsKey('code')) {
          try {
            await Supabase.instance.client.auth.getSessionFromUrl(Uri.base);
            if (kDebugMode) debugPrint('OAuth: sesión obtenida desde URL correctamente.');
          } catch (e, stack) {
            if (kDebugMode) debugPrint('OAuth getSessionFromUrl: $e');
            if (kDebugMode) debugPrint('$stack');
          }
        }

        // Si estamos en Web, mostramos advertencia sobre Realtime
        if (kIsWeb) {
          debugPrint("Flutter Web: Si aparecen errores de WebSocket, son esperados y no afectan la funcionalidad.");
        }
      } catch (e) {
        // Solo logueamos el error. La app abrirá igual en modo "Offline/Limitado"
        debugPrint("Advertencia: Supabase no conectó al inicio ($e). La app continuará.");
      }
    } else {
      debugPrint("Advertencia: Faltan credenciales de Supabase.");
    }

    return prefs;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: _initFuture,
      builder: (context, snapshot) {
        // A. PANTALLA DE CARGA (Logo simple)
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: Color(0xFF0A0A0A),
              body: Center(
                // Un loader simple para que sepas que está pensando
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              ),
            ),
          );
        }

        // B. SI FALLÓ ALGO VITAL (solo errores inesperados, ya que SharedPreferences tiene fallback)
        if (snapshot.hasError) {
           if (kDebugMode) debugPrint('Bootstrap error: ${snapshot.error}');
           if (kDebugMode && snapshot.stackTrace != null) debugPrint('${snapshot.stackTrace}');
           return MaterialApp(
             debugShowCheckedModeBanner: false,
             home: Scaffold(
               backgroundColor: const Color(0xFF0A0A0A),
               body: Center(
                 child: Padding(
                   padding: const EdgeInsets.all(32.0),
                   child: Column(
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                       const SizedBox(height: 16),
                       Text(
                         'Error al iniciar la app',
                         style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                         textAlign: TextAlign.center,
                       ),
                       const SizedBox(height: 12),
                       Text(
                         '${snapshot.error}',
                         style: const TextStyle(color: Colors.white70, fontSize: 13),
                         textAlign: TextAlign.center,
                       ),
                       const SizedBox(height: 24),
                       const Text(
                         'Posibles soluciones:\n'
                         '• Recargá la página (Ctrl+F5)\n'
                         '• Limpiá caché y cookies del sitio\n'
                         '• Probá en modo incógnito o con otro navegador\n'
                         '• Verificá que localStorage esté habilitado',
                         style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.5),
                         textAlign: TextAlign.center,
                       ),
                     ],
                   ),
                 ),
               ),
             ),
           );
        }

        // C. ÉXITO (Arrancamos la App real)
        // Nota que llegamos aquí INCLUSO si Supabase falló.
        final prefs = snapshot.data!;
        
        return ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const App(),
        );
      },
    );
  }
}