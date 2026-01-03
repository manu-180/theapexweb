// Archivo: lib/features/contact/data/repositories/appointment_repository.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:apex/core/providers/supabase_providers.dart';
import 'package:apex/features/contact/domain/models/appointment_model.dart';

part 'appointment_repository.g.dart';

class AppointmentRepository {
  final SupabaseClient _supabase;

  AppointmentRepository(this._supabase);

  Future<List<int>> getBookedHours(DateTime date) async {
    final dateString = date.toIso8601String().split('T')[0];
    final response = await _supabase
        .from('appointments')
        .select('hour_slot')
        .eq('date_slot', dateString);
    final List<dynamic> data = response;
    return data.map((e) => e['hour_slot'] as int).toList();
  }

  Future<void> createAppointment(Appointment appointment) async {
    try {
      await _supabase.from('appointments').insert(appointment.toJson());
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception('Lo sentimos, ese horario acaba de ser ocupado por otra persona.');
      }
      rethrow;
    }
  }

  // --- NUEVO: Envío de Email de Confirmación ---
  Future<void> sendBookingEmail({
    required String email,
    required String name,
    required DateTime date,
    required int hour,
  }) async {
    // Invocamos la Edge Function 'send-booking-email'
    await _supabase.functions.invoke(
      'send-booking-email',
      body: {
        'name': name,
        'email': email,
        'dateIso': date.toIso8601String(),
        'hour': hour,
      },
    );
  }
}

@riverpod
AppointmentRepository appointmentRepository(AppointmentRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AppointmentRepository(supabase);
}