// Archivo: lib/features/contact/presentation/widgets/booking_scheduler.dart
import 'dart:ui'; 
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
  final _scrollController = ScrollController(); 
  
  String _contactType = 'whatsapp'; 
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingNotifierProvider.notifier).selectDate(DateTime.now());
    });
  }

  @override
  void dispose() {
    _contactController.dispose();
    _nameController.dispose();
    _scrollController.dispose();
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

  void _scrollList(double offset) {
    if (!_scrollController.hasClients) return;
    final currentPos = _scrollController.offset;
    final targetPos = (currentPos + offset).clamp(
      0.0, 
      _scrollController.position.maxScrollExtent
    ); 
    
    _scrollController.animateTo(
      targetPos, 
      duration: const Duration(milliseconds: 300), 
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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

        // --- 1. CARRUSEL DE FECHAS MEJORADO ---
        SizedBox(
          height: 100, 
          child: Row(
            children: [
              IconButton(
                onPressed: () => _scrollList(-300),
                icon: const Icon(Icons.chevron_left_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                ),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
                  ),
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                    itemBuilder: (context, index) {
                      final date = DateTime.now().add(Duration(days: index));
                      final isSelected = _isSameDay(date, state.selectedDate);
                      final isSunday = date.weekday == DateTime.sunday;
                      final isToday = index == 0; // El índice 0 siempre es hoy en nuestra lógica
                      
                      // LOGICA VISUAL "HOY"
                      // Si es hoy, usamos el color primario suave aunque NO esté seleccionado.
                      final bgColor = isSelected
                          ? colorScheme.primary
                          : (isToday 
                              ? colorScheme.primary.withOpacity(0.15) // Hoy (no seleccionado)
                              : (isSunday ? colorScheme.surfaceContainerHighest.withOpacity(0.3) : colorScheme.surfaceContainerHighest));

                      final borderColor = isSelected
                          ? colorScheme.primary
                          : (isToday ? colorScheme.primary.withOpacity(0.5) : Colors.transparent);

                      final textColor = isSelected
                          ? colorScheme.onPrimary
                          : (isToday 
                              ? colorScheme.primary // Texto de "HOY" en color primario
                              : (isSunday ? colorScheme.outline : colorScheme.onSurfaceVariant));

                      // Etiqueta superior
                      final topLabel = isToday 
                          ? "HOY" 
                          : DateFormat('EEE', 'es').format(date).toUpperCase().replaceAll('.', '');

                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () => ref.read(bookingNotifierProvider.notifier).selectDate(date),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 75,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor, width: isToday && !isSelected ? 1.5 : 2),
                              boxShadow: isSelected 
                                  ? [BoxShadow(color: colorScheme.primary.withOpacity(0.4), blurRadius: 8, offset: const Offset(0,4))] 
                                  : null,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    topLabel,
                                    style: TextStyle(
                                      fontSize: 12, 
                                      fontWeight: FontWeight.bold,
                                      height: 1.0, 
                                      color: textColor,
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
                                      height: 1.0, 
                                      color: isSelected ? colorScheme.onPrimary : (isSunday ? colorScheme.outline : colorScheme.onSurface)
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _scrollList(300),
                icon: const Icon(Icons.chevron_right_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // --- 2. GRILLA DE HORARIOS (CON ESTADOS) ---
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: state.isLoading 
              ? _buildShimmerGrid(context)
              : (state.availableHours.isEmpty && state.selectedDate.weekday == DateTime.sunday) // Solo mostramos empty state si es Domingo cerrado
                  ? _buildEmptyState(context, isSunday: true)
                  : _buildHoursGrid(context, state),
        ),

        // 3. FORMULARIO
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

  static const int _minHour = 9;
  static const int _maxHour = 19;

  Widget _buildHoursGrid(BuildContext context, BookingState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final allHours = List.generate(11, (i) => _minHour + i);

    // Hora seleccionada: si no hay, usar la primera disponible o la primera del rango
    final current = state.selectedHour ?? (state.availableHours.isNotEmpty ? state.availableHours.first : _minHour);
    final hourPrev = current > _minHour ? current - 1 : null;
    final hourNext = current < _maxHour ? current + 1 : null;

    Widget buildHourRow(int? hour, bool isSelected) {
      if (hour == null) return const SizedBox(height: 48);
      final isAvailable = state.availableHours.contains(hour);
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isAvailable ? () => ref.read(bookingNotifierProvider.notifier).selectHour(hour) : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Center(
              child: Text(
                "$hour:00",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? colorScheme.onSurface
                      : colorScheme.onSurface.withOpacity(0.45),
                  decoration: isAvailable ? null : TextDecoration.lineThrough,
                  decorationColor: colorScheme.outline,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Horarios",
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (allHours.any((h) => !state.availableHours.contains(h)))
              Text(
                "Tachado = No disponible",
                style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.outline, fontSize: 10),
              ),
          ],
        ),
        const SizedBox(height: 16),
        // Solo 3 filas visibles: anterior (gris), seleccionada (negrita), siguiente (gris)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    buildHourRow(hourPrev, false),
                    buildHourRow(current, true),
                    buildHourRow(hourNext, false),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: hourPrev != null && state.availableHours.contains(hourPrev)
                        ? () => ref.read(bookingNotifierProvider.notifier).selectHour(hourPrev)
                        : null,
                    icon: Icon(Icons.keyboard_arrow_up, color: colorScheme.primary),
                  ),
                  IconButton(
                    onPressed: hourNext != null && state.availableHours.contains(hourNext)
                        ? () => ref.read(bookingNotifierProvider.notifier).selectHour(hourNext)
                        : null,
                    icon: Icon(Icons.keyboard_arrow_down, color: colorScheme.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingForm(BuildContext context, BookingState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
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
    final message = isSunday 
        ? "Domingos cerrados por descanso 🔋" 
        : "Agenda llena para este día";

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
            message,
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
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
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
      ),
    );
  }
}