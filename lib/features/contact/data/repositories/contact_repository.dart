// Archivo: lib/features/contact/data/repositories/contact_repository.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:apex/core/errors/app_exceptions.dart';
import 'package:apex/core/providers/supabase_providers.dart';

part 'contact_repository.g.dart';

class ContactRepository {
  final SupabaseClient? _supabase;

  ContactRepository(this._supabase);

  void _requireClient() {
    if (_supabase == null) {
      throw const InfrastructureException(
        'Servicio no disponible. Intenta de nuevo más tarde.',
        code: 'SUPABASE_NULL',
      );
    }
  }

  Future<void> sendContactMessage({
    required String name,
    required String email,
    required String message,
  }) async {
    _requireClient();
    final response = await _supabase!.functions.invoke(
      'send-contact-email',
      body: {
        'name': name,
        'email': email,
        'message': message,
      },
    );

    if (response.status != 200) {
      throw ProviderException(
        'Error al enviar el mensaje. Código: ${response.status}',
        code: 'EMAIL_SEND_FAILED',
      );
    }
  }
}

@riverpod
ContactRepository contactRepository(ContactRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ContactRepository(supabase);
}