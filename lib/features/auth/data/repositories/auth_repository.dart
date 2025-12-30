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
      // CORRECCIÓN: URL Dinámica.
      // En lugar de escribir el dominio a mano, dejamos que Dart detecte 
      // dónde está alojada la web (Uri.base.origin).
      // Esto funciona para: theapexweb.com, www.theapexweb.com, vercel.app, etc.
      String? redirectTo;
      
      if (kIsWeb) {
        if (kDebugMode) {
          // En modo Debug (localhost), pasamos null para que Supabase use 
          // la configuración por defecto del Dashboard (usualmente localhost:3000).
          redirectTo = null;
        } else {
          // En Producción, construimos la URL basada en el dominio actual.
          // Ejemplo: https://tu-dominio.com/#/contact
          redirectTo = '${Uri.base.origin}/#/contact';
        }
      } else {
        // En Android/iOS usamos el deep link nativo
        redirectTo = 'io.supabase.flutter://callback';
      }

      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google, 
        redirectTo: redirectTo,
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