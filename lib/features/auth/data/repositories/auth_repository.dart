// Archivo: lib/features/auth/data/repositories/auth_repository.dart
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint; // <<-- IMPORTADO debugPrint
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  AuthRepository(this._supabase);

  final SupabaseClient _supabase;

  /// Retorna un Stream que emite el [User] actual cuando el estado de auth cambia.
  Stream<User?> get authStateChanges => _supabase.auth.onAuthStateChange.map(
        (data) => data.session?.user,
      );
  
  /// Retorna el [User] actual, si existe.
  User? get currentUser => _supabase.auth.currentUser;

  /// Inicia el flujo de inicio de sesión con Google OAuth.
  Future<void> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google, // <<-- CORREGIDO: Usar OAuthProvider.google
        // La URL a la que Google debe redirigir después del login.
        redirectTo: kIsWeb ? null : 'io.supabase.flutter://callback',
      );
    } catch (e) {
      // Manejar el error (ej. mostrar SnackBar)
      debugPrint('Error en signInWithGoogle: $e');
      rethrow;
    }
  }

  /// Cierra la sesión del usuario actual.
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Error en signOut: $e');
      rethrow;
    }
  }
}