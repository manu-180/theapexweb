// Archivo: lib/features/contact/presentation/providers/appointment_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:apex/features/contact/data/repositories/appointment_repository.dart';
import 'package:apex/features/contact/data/repositories/whatsapp_repository.dart'; // <--- IMPORTANTE
import 'package:apex/features/contact/domain/models/appointment_model.dart';

part 'appointment_provider.g.dart';

// ... (BookingState queda igual) ...
class BookingState {
  final DateTime selectedDate;
  final List<int> availableHours; 
  final int? selectedHour;        
  final bool isLoading;
  final bool isSuccess;           

  BookingState({
    required this.selectedDate,
    this.availableHours = const [],
    this.selectedHour,
    this.isLoading = false,
    this.isSuccess = false,
  });

  BookingState copyWith({
    DateTime? selectedDate,
    List<int>? availableHours,
    int? selectedHour,
    bool? isLoading,
    bool? isSuccess,
  }) {
    return BookingState(
      selectedDate: selectedDate ?? this.selectedDate,
      availableHours: availableHours ?? this.availableHours,
      selectedHour: selectedHour ?? this.selectedHour,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

@riverpod
class BookingNotifier extends _$BookingNotifier {
  @override
  BookingState build() {
    final now = DateTime.now();
    return BookingState(selectedDate: now);
  }

  Future<void> selectDate(DateTime date) async {
    state = state.copyWith(
      selectedDate: date,
      selectedHour: null, 
      isLoading: true,
      isSuccess: false,
    );

    if (date.weekday == DateTime.sunday) {
      state = state.copyWith(availableHours: [], isLoading: false);
      return;
    }

    try {
      final repo = ref.read(appointmentRepositoryProvider);
      final bookedHours = await repo.getBookedHours(date);

      final List<int> allSlots = List.generate(11, (index) => 9 + index); 
      final freeSlots = allSlots.where((h) => !bookedHours.contains(h)).toList();

      final now = DateTime.now();
      final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
      
      if (isToday) {
        freeSlots.removeWhere((h) => h <= now.hour);
      }

      state = state.copyWith(availableHours: freeSlots, isLoading: false);
    } catch (e) {
      state = state.copyWith(availableHours: [], isLoading: false);
    }
  }

  void selectHour(int hour) {
    state = state.copyWith(selectedHour: hour);
  }

  // --- CONFIRMACIÓN CON NOTIFICACIONES AUTOMÁTICAS ---
  Future<void> confirmBooking({
    required String contactInfo,
    required String contactType, // 'whatsapp' o 'email'
    String? name,
  }) async {
    if (state.selectedHour == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final appRepo = ref.read(appointmentRepositoryProvider);
      
      // 1. Crear Reserva en BD
      final appointment = Appointment(
        dateSlot: state.selectedDate,
        hourSlot: state.selectedHour!,
        contactInfo: contactInfo,
        contactType: contactType,
        clientName: name,
      );

      await appRepo.createAppointment(appointment);
      
      // 2. DISPARAR NOTIFICACIONES (Fire and Forget)
      // No usamos 'await' bloqueante para que el usuario vea el éxito rápido
      _sendNotification(contactType, contactInfo, name ?? 'Cliente');

      // 3. Éxito
      state = state.copyWith(isLoading: false, isSuccess: true);
      
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow; 
    }
  }

  Future<void> _sendNotification(String type, String contact, String name) async {
    try {
      if (type == 'whatsapp') {
        final wppRepo = ref.read(whatsappRepositoryProvider);
        await wppRepo.sendBookingConfirmation(
          phone: contact, 
          date: state.selectedDate, 
          hour: state.selectedHour!
        );
      } else if (type == 'email') {
        final appRepo = ref.read(appointmentRepositoryProvider);
        await appRepo.sendBookingEmail(
          email: contact,
          name: name,
          date: state.selectedDate,
          hour: state.selectedHour!,
        );
      }
    } catch (e) {
      // Loguear error silencioso (analytics)
      print("Error enviando notificación automática: $e");
    }
  }
  
  void reset() {
    state = build();
  }
}