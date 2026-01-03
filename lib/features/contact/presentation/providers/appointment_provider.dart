// Archivo: lib/features/contact/presentation/providers/appointment_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:apex/features/contact/data/repositories/appointment_repository.dart';
import 'package:apex/features/contact/domain/models/appointment_model.dart';

part 'appointment_provider.g.dart';

// --- ESTADO DE LA UI ---
class BookingState {
  final DateTime selectedDate;
  final List<int> availableHours; // Las horas que SI se pueden elegir
  final int? selectedHour;        // La hora que el usuario tocó (si tocó alguna)
  final bool isLoading;
  final bool isSuccess;           // Para mostrar el check verde final

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
    // Iniciamos hoy, pero reseteamos horas
    final now = DateTime.now();
    return BookingState(selectedDate: now);
  }

  /// Lógica principal: El usuario toca un día en el calendario
  Future<void> selectDate(DateTime date) async {
    // 1. Reset visual inmediato (optimista)
    state = state.copyWith(
      selectedDate: date,
      selectedHour: null, // Reseteamos la hora seleccionada anterior
      isLoading: true,
      isSuccess: false,
    );

    // 2. Regla de Negocio: DOMINGOS CERRADO
    if (date.weekday == DateTime.sunday) {
      state = state.copyWith(availableHours: [], isLoading: false);
      return;
    }

    try {
      // 3. Consultamos qué está ocupado en la BD
      final repo = ref.read(appointmentRepositoryProvider);
      final bookedHours = await repo.getBookedHours(date);

      // 4. Calculamos libres (Regla: 9 a 19hs)
      final List<int> allSlots = List.generate(11, (index) => 9 + index); // [9, 10 ... 19]
      
      // Filtramos: Sacamos las ocupadas
      final freeSlots = allSlots.where((h) => !bookedHours.contains(h)).toList();

      // Filtro extra: Si es HOY, no mostrar horas que ya pasaron
      final now = DateTime.now();
      final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
      
      if (isToday) {
        freeSlots.removeWhere((h) => h <= now.hour);
      }

      state = state.copyWith(
        availableHours: freeSlots,
        isLoading: false,
      );
    } catch (e) {
      // Si falla, dejamos lista vacía para seguridad
      state = state.copyWith(availableHours: [], isLoading: false);
    }
  }

  void selectHour(int hour) {
    state = state.copyWith(selectedHour: hour);
  }

  Future<void> confirmBooking({
    required String contactInfo,
    required String contactType, // 'whatsapp' o 'email'
    String? name,
  }) async {
    if (state.selectedHour == null) return;

    state = state.copyWith(isLoading: true);

    try {
      final repo = ref.read(appointmentRepositoryProvider);
      
      final appointment = Appointment(
        dateSlot: state.selectedDate,
        hourSlot: state.selectedHour!,
        contactInfo: contactInfo,
        contactType: contactType,
        clientName: name,
      );

      await repo.createAppointment(appointment);
      
      // Éxito total
      state = state.copyWith(isLoading: false, isSuccess: true);
      
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow; // La UI manejará el error (Toast/SnackBar)
    }
  }
  
  void reset() {
    state = build();
  }
}