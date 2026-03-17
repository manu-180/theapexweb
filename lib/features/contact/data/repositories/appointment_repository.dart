// Archivo: lib/features/contact/data/repositories/appointment_repository.dart
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:apex/core/errors/app_exceptions.dart';
import 'package:apex/core/providers/supabase_providers.dart';
import 'package:apex/features/contact/domain/models/appointment_model.dart';

part 'appointment_repository.g.dart';

class AppointmentRepository {
  final SupabaseClient? _supabase;

  AppointmentRepository(this._supabase);

  void _requireClient() {
    if (_supabase == null) {
      throw const InfrastructureException(
        'Reservas temporalmente no disponibles. Comprueba tu conexión o inténtalo más tarde.',
        code: 'SUPABASE_NULL',
      );
    }
  }

  Future<List<int>> getBookedHours(DateTime date) async {
    _requireClient();
    final dateString = date.toIso8601String().split('T')[0];
    try {
      final response = await _supabase!
          .from('appointments')
          .select('hour_slot')
          .eq('date_slot', dateString);
      final List<dynamic> data = response;
      return data.map((e) => e['hour_slot'] as int).toList();
    } catch (e, stack) {
      debugPrint('[AppointmentRepository] getBookedHours error: $e');
      debugPrint('[AppointmentRepository] Stack: $stack');
      rethrow;
    }
  }

  Future<void> createAppointment(Appointment appointment) async {
    _requireClient();
    try {
      await _supabase!.from('appointments').insert(appointment.toJson());
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw const ValidationException(
          'Lo sentimos, ese horario acaba de ser ocupado por otra persona.',
          code: 'SLOT_TAKEN',
        );
      }
      rethrow;
    }
  }

  Future<void> sendBookingEmail({
    required String email,
    required String name,
    required DateTime date,
    required int hour,
  }) async {
    _requireClient();
    final response = await _supabase!.functions.invoke(
      'send-booking-email',
      body: {
        'name': name,
        'email': email,
        'dateIso': date.toIso8601String(),
        'hour': hour,
      },
    );

    if (response.status != 200) {
      throw ProviderException(
        'Error al enviar la confirmación. Código: ${response.status}',
        code: 'BOOKING_EMAIL_FAILED',
      );
    }
  }
}

@riverpod
AppointmentRepository appointmentRepository(AppointmentRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AppointmentRepository(supabase);
}