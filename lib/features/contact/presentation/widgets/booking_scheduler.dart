// Archivo: lib/features/contact/presentation/widgets/booking_scheduler.dart
import 'package:animate_do/animate_do.dart';
import 'package:apex/features/contact/presentation/providers/appointment_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class BookingScheduler extends ConsumerStatefulWidget {
  const BookingScheduler({super.key});

  @override
  ConsumerState<BookingScheduler> createState() => _BookingSchedulerState();
}

class _BookingSchedulerState extends ConsumerState<BookingScheduler> {
  final _contactController = TextEditingController();
  final _nameController = TextEditingController();
  String _contactType = 'whatsapp'; // whatsapp | email
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Iniciamos cargando la disponibilidad de hoy
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingNotifierProvider.notifier).selectDate(DateTime.now());
    });
  }

  @override
  void dispose() {
    _contactController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    
    ref.read(bookingNotifierProvider.notifier).confirmBooking(
      contactInfo: _contactController.text.trim(),
      contactType: _contactType,
      name: _nameController.text.trim().isEmpty ? null : _nameController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // --- ESTADO DE ÉXITO (ANIMACIÓN FINAL) ---
    if (state.isSuccess) {
      return FadeIn(
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.green.withOpacity(0.5)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 64),
              const SizedBox(height: 20),
              Text(
                "¡Reunión Agendada!",
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.green),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Te contactaré brevemente para confirmar los detalles.",
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => ref.read(bookingNotifierProvider.notifier).reset(),
                child: const Text("Agendar otra"),
              )
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // CABECERA
        Row(
          children: [
            Icon(FontAwesomeIcons.calendarCheck, color: colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              "Reserva tu lugar",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: 'Oxanium',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          "Selecciona un día y horario para tener una reunión 1 a 1 conmigo.",
          style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),

        // 1. SELECTOR DE FECHAS BLINDADO (Deterministic Layout)
        // Fijamos una altura generosa en el padre (130px)
        SizedBox(
          height: 130, 
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 30, // Próximos 30 días
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            itemBuilder: (context, index) {
              final date = DateTime.now().add(Duration(days: index));
              final isSelected = _isSameDay(date, state.selectedDate);
              final isSunday = date.weekday == DateTime.sunday;
              
              return GestureDetector(
                onTap: () => ref.read(bookingNotifierProvider.notifier).selectDate(date),
                child: Container(
                  // Margen externo (no afecta el tamaño interno de la caja)
                  margin: const EdgeInsets.only(right: 12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    // --- RESTRICCIÓN DETERMINISTA ---
                    // Fijamos dimensiones explícitas. 90px < 130px (Safety Buffer ok)
                    width: 75,
                    height: 90,
                    alignment: Alignment.center, // Alineación central desacoplada
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? colorScheme.primary 
                          : (isSunday ? colorScheme.surfaceContainerHighest.withOpacity(0.3) : colorScheme.surfaceContainerHighest),
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected 
                          ? Border.all(color: colorScheme.primary, width: 2)
                          : Border.all(color: Colors.transparent),
                      boxShadow: isSelected 
                          ? [BoxShadow(color: colorScheme.primary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0,4))] 
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min, // Intrinsic sizing mínimo
                      children: [
                        // FittedBox asegura que el texto nunca desborde si la fuente cambia
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            DateFormat('EEE', 'es').format(date).toUpperCase().replaceAll('.', ''),
                            style: TextStyle(
                              fontSize: 12, 
                              fontWeight: FontWeight.bold,
                              height: 1.0, // Normalización de métrica de fuente
                              color: isSelected ? colorScheme.onPrimary : (isSunday ? colorScheme.outline : colorScheme.onSurfaceVariant)
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            date.day.toString(),
                            style: TextStyle(
                              fontSize: 22, 
                              fontWeight: FontWeight.bold,
                              height: 1.0, // Normalización de métrica de fuente
                              color: isSelected ? colorScheme.onPrimary : (isSunday ? colorScheme.outline : colorScheme.onSurface)
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 32),

        // 2. GRILLA DE HORARIOS
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: state.isLoading 
              ? _buildShimmerGrid(context)
              : state.availableHours.isEmpty
                  ? _buildEmptyState(context, isSunday: state.selectedDate.weekday == DateTime.sunday)
                  : _buildHoursGrid(context, state),
        ),

        // 3. FORMULARIO DE CONTACTO (Solo si hay hora seleccionada)
        AnimatedSize(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutExpo,
          child: state.selectedHour == null 
              ? const SizedBox.shrink()
              : _buildBookingForm(context, state),
        ),
      ],
    );
  }

  Widget _buildHoursGrid(BuildContext context, BookingState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text(
          "Horarios Disponibles (${state.availableHours.length})",
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: state.availableHours.map((hour) {
            final isSelected = state.selectedHour == hour;
            return GestureDetector(
              onTap: () => ref.read(bookingNotifierProvider.notifier).selectHour(hour),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.3)
                  ),
                  boxShadow: isSelected 
                      ? [BoxShadow(color: colorScheme.primary.withOpacity(0.3), blurRadius: 8)] 
                      : null
                ),
                child: Text(
                  "$hour:00",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBookingForm(BuildContext context, BookingState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Formateamos la fecha seleccionada para mostrarla bonita
    final dateStr = DateFormat('EEEE d \'de\' MMMM', 'es').format(state.selectedDate);
    final hourStr = "${state.selectedHour}:00 hs";

    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      child: Container(
        margin: const EdgeInsets.only(top: 40),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.event_available, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Confirmar Reserva", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                        Text("$dateStr a las $hourStr", style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.primary)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              
              // Selector Tipo Contacto
              Row(
                children: [
                  _ContactTypeChip(
                    label: "WhatsApp",
                    icon: FontAwesomeIcons.whatsapp,
                    isSelected: _contactType == 'whatsapp',
                    onTap: () => setState(() => _contactType = 'whatsapp'),
                    color: const Color(0xFF25D366),
                  ),
                  const SizedBox(width: 12),
                  _ContactTypeChip(
                    label: "Email",
                    icon: Icons.email_outlined,
                    isSelected: _contactType == 'email',
                    onTap: () => setState(() => _contactType = 'email'),
                    color: colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _contactController,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Este campo es requerido';
                  if (_contactType == 'email' && !v.contains('@')) return 'Email inválido';
                  return null;
                },
                decoration: InputDecoration(
                  labelText: _contactType == 'whatsapp' ? 'Tu número (+54...)' : 'Tu Email',
                  prefixIcon: Icon(_contactType == 'whatsapp' ? Icons.phone : Icons.email, size: 18),
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Tu Nombre (Opcional)',
                  prefixIcon: const Icon(Icons.person_outline, size: 18),
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: state.isLoading ? null : _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: state.isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text("Confirmar Reunión", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, {required bool isSunday}) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            isSunday ? Icons.weekend_rounded : Icons.event_busy_rounded, 
            size: 40, 
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)
          ),
          const SizedBox(height: 12),
          Text(
            isSunday ? "Los domingos descanso 😴" : "Agenda llena para este día",
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          if (!isSunday)
            TextButton(
              onPressed: () {}, 
              child: const Text("Busca otro día ->"),
            )
        ],
      ),
    );
  }

  Widget _buildShimmerGrid(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: List.generate(8, (index) => Container(
          width: 80, height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        )),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _ContactTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _ContactTypeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Theme.of(context).dividerColor,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? color : Theme.of(context).iconTheme.color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}