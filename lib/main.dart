import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apex/app.dart';
import 'package:apex/core/config/theme/app_theme_providers.dart';
import 'package:apex/core/config/env_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:web/web.dart' as web;

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

/// Limpia el ?code= de la URL del navegador tras el callback OAuth.
/// Esto evita que al refrescar la página se intente reusar un código ya consumido.
void _cleanOAuthCodeFromUrl() {
  if (!kIsWeb) return;
  try {
    final uri = Uri.base;
    // Reconstruimos la URL sin el parámetro 'code'
    final cleanParams = Map<String, String>.from(uri.queryParameters)..remove('code');
    final cleanUri = uri.replace(queryParameters: cleanParams.isEmpty ? null : cleanParams);
    web.window.history.replaceState(null, '', cleanUri.toString());
    debugPrint('OAuth: URL limpiada correctamente.');
  } catch (e) {
    debugPrint('OAuth: No se pudo limpiar la URL: $e');
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
    // 1. Cargar .env y SharedPreferences
    late SharedPreferences prefs;
    await Future.wait([
      EnvConfig.load(),
      SharedPreferences.getInstance().then((p) => prefs = p).catchError((Object e, StackTrace stack) {
        debugPrint('[Bootstrap] SharedPreferences fallback: $e');
        if (kDebugMode) debugPrint('$stack');
        prefs = _InMemorySharedPreferences();
        return prefs;
      }),
    ]);

    // 2. Inicializar Supabase con las credenciales del config (antes de mostrar la app)
    await _initSupabase();

    return prefs;
  }

  Future<void> _initSupabase() async {
    final url = EnvConfig.supabaseUrl;
    final key = EnvConfig.supabaseAnonKey;
    if (url.isEmpty || key.isEmpty) {
      debugPrint('[Bootstrap] Supabase: sin credenciales (usa .env o --dart-define=SUPABASE_URL / SUPABASE_ANON_KEY).');
      return;
    }

    final hasOAuthCode = kIsWeb && Uri.base.queryParameters.containsKey('code');

    try {
      await Supabase.initialize(
        url: url,
        anonKey: key,
        realtimeClientOptions: RealtimeClientOptions(
          eventsPerSecond: 10,
          logLevel: kIsWeb ? RealtimeLogLevel.error : RealtimeLogLevel.info,
        ),
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
          detectSessionInUri: false,
        ),
      ).timeout(const Duration(seconds: 10));

      if (kDebugMode) debugPrint('[Bootstrap] Supabase conectado: $url');

      if (hasOAuthCode) {
        final code = Uri.base.queryParameters['code']!;
        try {
          await Supabase.instance.client.auth.exchangeCodeForSession(code);
          debugPrint('[OAuth] Session established.');
        } catch (e) {
          debugPrint('[OAuth] Exchange failed: $e');
        }
        _cleanOAuthCodeFromUrl();
      }
    } catch (e) {
      debugPrint('[Bootstrap] Supabase init failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SharedPreferences>(
      future: _initFuture,
      builder: (context, snapshot) {
        // A. PANTALLA DE CARGA: mismo AppBar (altura y espacio lateral) que MainLayout
        // para evitar salto lateral de la barra/flechita al terminar de cargar.
        if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: Color(0xFF0A0A0A),
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(kToolbarHeight),
                child: AppBar(
                  backgroundColor: const Color(0xFF0A0A0A),
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  leadingWidth: 56,
                  toolbarHeight: kToolbarHeight,
                ),
              ),
              body: Center(
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