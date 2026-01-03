// Archivo: lib/features/contact/data/repositories/appointment_repository.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:apex/core/providers/supabase_providers.dart';
import 'package:apex/features/contact/domain/models/appointment_model.dart';

part 'appointment_repository.g.dart';

class AppointmentRepository {
  final SupabaseClient _supabase;

  AppointmentRepository(this._supabase);

  /// Obtiene la lista de HORAS ocupadas para una fecha específica.
  /// Retorna una lista de enteros (ej: [9, 10, 14])
  Future<List<int>> getBookedHours(DateTime date) async {
    // Formateamos la fecha a YYYY-MM-DD para coincidir con la columna 'date' de Postgres
    final dateString = date.toIso8601String().split('T')[0];

    final response = await _supabase
        .from('appointments')
        .select('hour_slot')
        .eq('date_slot', dateString);

    // Mapeamos la respuesta a una lista simple de enteros
    final List<dynamic> data = response;
    return data.map((e) => e['hour_slot'] as int).toList();
  }

  /// Guarda una nueva reserva
  Future<void> createAppointment(Appointment appointment) async {
    try {
      await _supabase.from('appointments').insert(appointment.toJson());
    } on PostgrestException catch (e) {
      // Código 23505 es violación de unique constraint (Duplicado)
      if (e.code == '23505') {
        throw Exception('Lo sentimos, ese horario acaba de ser ocupado por otra persona.');
      }
      rethrow;
    }
  }
}

@riverpod
AppointmentRepository appointmentRepository(AppointmentRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AppointmentRepository(supabase);
}