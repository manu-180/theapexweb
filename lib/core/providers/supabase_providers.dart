// Archivo: lib/core/providers/supabase_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_providers.g.dart';

/// Provider que expone el cliente de Supabase a toda la app.
/// Retorna null si Supabase no fue inicializado (p. ej. web sin credenciales),
/// para que la UI de presencia y auth no lance y muestre estado "sin conexión".
@riverpod
SupabaseClient? supabaseClient(SupabaseClientRef ref) {
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
}