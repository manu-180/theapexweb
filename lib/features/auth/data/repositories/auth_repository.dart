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
        // CORRECCIÓN: Evitamos problemas con fragments en la URL base
        // Si estamos en https://midominio.com/#/contact, queremos redireccionar a la raíz
        // o a una ruta limpia.
        String origin = Uri.base.origin;
        if (!origin.startsWith('http')) {
           // Fallback por si origin viene vacío en algunos navegadores
           origin = Uri.base.scheme + '://' + Uri.base.host;
           if (Uri.base.hasPort) origin += ':${Uri.base.port}';
        }

        if (kDebugMode) {
          redirectTo = null; // Supabase usa localhost:3000 por defecto
        } else {
          // IMPORTANTE: Asegúrate de tener esta URL exacta en "Redirect URLs" en Supabase
          redirectTo = '$origin/'; // Redirigimos al Home para evitar problemas con hashes
        }
      } else {
        redirectTo = 'io.supabase.flutter://callback';
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