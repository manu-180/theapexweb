// Archivo: lib/features/auth/data/repositories/auth_repository.dart
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint, kDebugMode; 
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
        OAuthProvider.google, 
        // LÓGICA DE REDIRECCIÓN INTELIGENTE:
        // 1. Si es Web en Producción -> Vamos directo a la sección de contacto.
        // 2. Si es Web en Desarrollo (localhost) -> Dejamos null para que use la Site URL por defecto.
        // 3. Si es Móvil -> Usamos el esquema de deep link.
        redirectTo: kIsWeb 
            ? (kDebugMode ? null : 'https://theapexweb.com/#/contact') 
            : 'io.supabase.flutter://callback',
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