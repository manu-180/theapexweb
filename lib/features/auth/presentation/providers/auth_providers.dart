// Archivo: lib/features/auth/presentation/providers/auth_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prueba_de_riverpod/core/providers/supabase_providers.dart';
import 'package:prueba_de_riverpod/features/auth/data/repositories/auth_repository.dart';

part 'auth_providers.g.dart';

/// Provider para la capa de repositorio de Autenticación.
/// 
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  // Inyectamos el cliente de Supabase en el repositorio.
  final supabaseClient = ref.watch(supabaseClientProvider);
  return AuthRepository(supabaseClient);
}

/// Provider que expone el STREAM del estado de autenticación.
///
/// La UI escuchará a este provider para saber EN TIEMPO REAL
/// si el usuario está logueado o no.
/// 
@riverpod
Stream<User?> authStateStream(AuthStateStreamRef ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.authStateChanges;
}

/// Provider que expone el USUARIO ACTUAL (sincrónicamente).
@riverpod
User? currentUser(CurrentUserRef ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return authRepository.currentUser;
}