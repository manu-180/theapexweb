// Archivo: lib/features/contact/data/repositories/contact_repository.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:apex/core/providers/supabase_providers.dart';

part 'contact_repository.g.dart';

class ContactRepository {
  final SupabaseClient? _supabase;

  ContactRepository(this._supabase);

  Future<void> sendContactMessage({
    required String name,
    required String email,
    required String message,
  }) async {
    if (_supabase == null) return;
    await _supabase!.functions.invoke(
      'send-contact-email',
      body: {
        'name': name,
        'email': email,
        'message': message,
      },
    );
  }
}

@riverpod
ContactRepository contactRepository(ContactRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ContactRepository(supabase);
}