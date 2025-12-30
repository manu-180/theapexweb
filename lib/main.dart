import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apex/app.dart';
import 'package:apex/core/config/theme/app_theme_providers.dart';
import 'package:apex/core/config/env_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Provider global para la URL
final supabaseUrlProvider = Provider<String>((ref) => EnvConfig.supabaseUrl);

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
  late Future<SharedPreferences?> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeApp();
  }

  Future<SharedPreferences?> _initializeApp() async {
    // 1. Carga de Entorno (Silenciosa si falla)
    await EnvConfig.load();

    // 2. Preferencias (Esto es lo único vital para que Riverpod no falle)
    final prefs = await SharedPreferences.getInstance();

    // 3. Validación y Supabase (Intento optimista)
    final url = EnvConfig.supabaseUrl;
    final key = EnvConfig.supabaseAnonKey;

    if (url.isNotEmpty && key.isNotEmpty) {
      try {
        // Intentamos conectar, pero si falla, NO detenemos la app.
        await Supabase.initialize(
          url: url,
          anonKey: key,
          realtimeClientOptions: const RealtimeClientOptions(
            eventsPerSecond: 10,
          ),
        ).timeout(const Duration(seconds: 5)); // Timeout corto para no hacer esperar
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
    return FutureBuilder<SharedPreferences?>(
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

        // B. SI FALLÓ ALGO VITAL (SharedPreferences) - Muy raro
        if (snapshot.hasError || snapshot.data == null) {
           // Fallback de emergencia si SharedPreferences muere (casi imposible)
           // Retornamos una app básica para no crashear
           return MaterialApp(
             home: Scaffold(body: Center(child: Text("Error crítico de memoria: ${snapshot.error}"))),
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