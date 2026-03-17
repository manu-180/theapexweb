// Archivo: lib/features/contact/presentation/providers/appointment_provider.dart
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:apex/core/errors/app_exceptions.dart';
import 'package:apex/features/contact/data/repositories/appointment_repository.dart';
import 'package:apex/features/contact/data/repositories/whatsapp_repository.dart';
import 'package:apex/features/contact/domain/models/appointment_model.dart';

part 'appointment_provider.g.dart';

class BookingState {
  final DateTime selectedDate;
  final List<int> availableHours;
  final int? selectedHour;
  final bool isLoading;
  final bool isSuccess;
  final String? errorMessage;

  BookingState({
    required this.selectedDate,
    this.availableHours = const [],
    this.selectedHour,
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage,
  });

  const BookingState._({
    required this.selectedDate,
    required this.availableHours,
    required this.selectedHour,
    required this.isLoading,
    required this.isSuccess,
    required this.errorMessage,
  });

  bool get hasError => errorMessage != null;

  BookingState copyWith({
    DateTime? selectedDate,
    List<int>? availableHours,
    int? selectedHour,
    bool clearSelectedHour = false,
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
    bool clearError = false,
  }) {
    return BookingState._(
      selectedDate: selectedDate ?? this.selectedDate,
      availableHours: availableHours ?? this.availableHours,
      selectedHour: clearSelectedHour ? null : (selectedHour ?? this.selectedHour),
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

@riverpod
class BookingNotifier extends _$BookingNotifier {
  bool _isSubmitting = false;

  @override
  BookingState build() {
    final now = DateTime.now();
    return BookingState(selectedDate: now);
  }

  Future<void> selectDate(DateTime date) async {
    state = state.copyWith(
      selectedDate: date,
      clearSelectedHour: true,
      isLoading: true,
      isSuccess: false,
      clearError: true,
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
    } on AppException catch (e) {
      debugPrint('[Booking] Error al cargar horarios (AppException): ${e.message}');
      state = state.copyWith(
        availableHours: [],
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e, stack) {
      debugPrint('[Booking] Error al cargar horarios: $e');
      debugPrint('[Booking] Stack: $stack');
      final msg = e.toString().toLowerCase();
      final isNetworkError = msg.contains('name not resolved') ||
          msg.contains('connection') ||
          msg.contains('socket') ||
          msg.contains('network') ||
          msg.contains('failed to load');
      state = state.copyWith(
        availableHours: [],
        isLoading: false,
        errorMessage: isNetworkError
            ? 'No se pudo conectar al servidor. Comprueba tu conexión a internet e inténtalo de nuevo.'
            : 'Error al cargar horarios. Intenta de nuevo.',
      );
    }
  }

  void selectHour(int hour) {
    state = state.copyWith(selectedHour: hour, clearError: true);
  }

  Future<void> confirmBooking({
    required String contactInfo,
    required String contactType,
    String? name,
  }) async {
    if (state.selectedHour == null || _isSubmitting) return;

    _isSubmitting = true;
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final appRepo = ref.read(appointmentRepositoryProvider);

      final appointment = Appointment(
        dateSlot: state.selectedDate,
        hourSlot: state.selectedHour!,
        contactInfo: contactInfo,
        contactType: contactType,
        clientName: name,
      );

      await appRepo.createAppointment(appointment);

      _sendNotification(contactType, contactInfo, name ?? 'Cliente');

      state = state.copyWith(isLoading: false, isSuccess: true);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No se pudo confirmar la reserva. Intenta de nuevo.',
      );
    } finally {
      _isSubmitting = false;
    }
  }

  Future<void> _sendNotification(String type, String contact, String name) async {
    try {
      if (type == 'whatsapp') {
        final wppRepo = ref.read(whatsappRepositoryProvider);
        await wppRepo.sendBookingConfirmation(
          phone: contact,
          date: state.selectedDate,
          hour: state.selectedHour!,
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
      debugPrint('Error enviando notificación automática: $e');
    }
  }

  void reset() {
    _isSubmitting = false;
    state = build();
  }
}