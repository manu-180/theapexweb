// Archivo: lib/features/contact/domain/models/appointment_model.dart

class Appointment {
  final int? id;
  final DateTime dateSlot;
  final int hourSlot;
  final String contactInfo;
  final String contactType; // 'email' | 'whatsapp'
  final String? clientName;

  const Appointment({
    this.id,
    required this.dateSlot,
    required this.hourSlot,
    required this.contactInfo,
    required this.contactType,
    this.clientName,
  });

  Map<String, dynamic> toJson() {
    return {
      // Supabase espera formato YYYY-MM-DD para columnas tipo Date
      'date_slot': dateSlot.toIso8601String().split('T')[0],
      'hour_slot': hourSlot,
      'contact_info': contactInfo,
      'contact_type': contactType,
      'client_name': clientName,
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      dateSlot: DateTime.parse(json['date_slot']),
      hourSlot: json['hour_slot'],
      contactInfo: json['contact_info'],
      contactType: json['contact_type'],
      clientName: json['client_name'],
    );
  }
}