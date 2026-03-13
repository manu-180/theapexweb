// Archivo: lib/features/auth/data/repositories/auth_repository.dart
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint, kDebugMode;
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository(this._supabase);

  final SupabaseClient? _supabase;

  Stream<User?> get authStateChanges => _supabase != null
      ? _supabase.auth.onAuthStateChange.map((data) => data.session?.user)
      : const Stream.empty();

  User? get currentUser => _supabase?.auth.currentUser;

  /// Retorna true si se inició el flujo OAuth, false si no hay cliente (ej. faltan credenciales).
  Future<bool> signInWithGoogle() async {
    if (_supabase == null) {
      debugPrint('Login con Google: no disponible (faltan credenciales de Supabase).');
      return false;
    }
    try {
      String? redirectTo;

      if (kIsWeb) {
        // Usamos una URL estable (sin query/fragment) para evitar callbacks inconsistentes.
        final base = Uri.base;
        final normalizedPath = (base.path.isEmpty || base.path == '/')
            ? '/'
            : (base.path.endsWith('/') ? base.path : '${base.path}/');
        redirectTo = Uri(
          scheme: base.scheme,
          host: base.host,
          port: base.hasPort ? base.port : null,
          path: normalizedPath,
        ).toString();
      } else {
        redirectTo = 'io.supabase.flutter://callback';
      }

      if (kDebugMode) {
        debugPrint('OAuth redirectTo: $redirectTo');
      }

      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectTo,
      );
      return true;
    } catch (e) {
      debugPrint('Error en signInWithGoogle: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (_supabase == null) return;
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Error en signOut: $e');
      rethrow;
    }
  }
}