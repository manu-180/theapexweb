// Archivo: lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prueba_de_riverpod/app.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Definimos un Provider simple para la URL de Supabase
final supabaseUrlProvider = Provider<String>((ref) => throw UnimplementedError());

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Cargar variables de entorno
  await dotenv.load(fileName: ".env");

  // Obtener la URL antes de Supabase.initialize
  final supabaseUrl = dotenv.env['SUPABASE_URL']!;

  // 2. Inicializar Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // 3. Ejecutar la app
  runApp(
    ProviderScope(
      overrides: [
        // Proveemos la URL para que el MercadoPagoRepository la use
        supabaseUrlProvider.overrideWithValue(supabaseUrl),
      ],
      child: const App(),
    ),
  );
}